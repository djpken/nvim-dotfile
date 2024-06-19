local config = {}
local symbols = Kk.symbols
local config_root = string.gsub(vim.fn.stdpath("config"), "\\", "/")
local priority = { LOW = 100, MEDIUM = 200, HIGH = 615 }

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    local function _trigger()
      vim.api.nvim_exec_autocmds("User", { pattern = "KkLoad" })
    end

    if vim.bo.filetype == "dashboard" then
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*/*",
        once = true,
        callback = _trigger,
      })
    else
      _trigger()
    end
  end,
})
local nvim_tree_opts = {
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")
    local opt = { buffer = bufnr, noremap = true, silent = true }

    api.config.mappings.default_on_attach(bufnr)

    require("core.utils").group_map({
      edit = {
        "n",
        "<CR>",
        function()
          local node = api.tree.get_node_under_cursor()
          if node.name ~= ".." and node.fs_stat.type == "file" then
            -- Taken partially from:
            -- https://support.microsoft.com/en-us/windows/common-file-name-extensions-in-windows-da4a4430-8e76-89c5-59f7-1cdbbc75cb01
            --
            -- Not all are included for speed's sake
            local extensions_opened_externally = {
              "avi",
              "bmp",
              "doc",
              "docx",
              "exe",
              "flv",
              "gif",
              "jpg",
              "jpeg",
              "m4a",
              "mov",
              "mp3",
              "mp4",
              "mpeg",
              "mpg",
              "pdf",
              "png",
              "ppt",
              "pptx",
              "psd",
              "pub",
              "rar",
              "rtf",
              "tif",
              "tiff",
              "wav",
              "xls",
              "xlsx",
              "zip",
            }
            if table.find(extensions_opened_externally, node.extension) then
              api.node.run.system()
              return
            end
          end

          api.node.open.edit()
        end,
      },
      vertical_split = { "n", "V", api.node.open.vertical },
      horizontal_split = { "n", "H", api.node.open.horizontal },
      toggle_hidden_file = { "n", ".", api.tree.toggle_hidden_filter },
      reload = { "n", "<F5>", api.tree.reload },
      create = { "n", "a", api.fs.create },
      remove = { "n", "d", api.fs.remove },
      rename = { "n", "r", api.fs.rename },
      cut = { "n", "x", api.fs.cut },
      copy = { "n", "y", api.fs.copy.node },
      paste = { "n", "p", api.fs.paste },
      system_run = { "n", "s", api.node.run.system },
      show_info = { "n", "i", api.node.show_info_popup },
    }, opt)
  end,
  git = { enable = false },
  update_focused_file = { enable = true },
  filters = {
    dotfiles = false,
    custom = { "node_modules", ".git/" },
    exclude = { ".gitignore" },
  },
  respect_buf_cwd = true,
  view = {
    width = 30,
    side = "left",
    number = false,
    relativenumber = false,
    signcolumn = "yes",
  },
  sort = { sorter = "case_sensitive" },
  actions = { open_file = { resize_window = true, quit_on_open = false } },
  renderer = { group_empty = true },
}

config.bufferline = {
  "akinsho/bufferline.nvim",
  dependencies = { "moll/vim-bbye", "nvim-tree/nvim-web-devicons" },
  event = "User KkLoad",
  opts = {
    options = {
      close_command = ":BufferLineClose %d",
      right_mouse_command = ":BufferLineClose %d",
      separator_style = "thin",
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      },
      diagnostics_indicator = function(_, _, diagnostics_dict, _)
        local s = " "
        for e, n in pairs(diagnostics_dict) do
          local sym = e == "error" and symbols.Error or (e == "warning" and symbols.Warn or symbols.Info)
          s = s .. n .. sym
        end
        return s
      end,
      diagnostics = "nvim_lsp",
      show_buffer_close_icons = false,
      show_close_icon = false,
      color_icons = false,
    },
    highlights = {
      separator = { guifg = "#073642", guibg = "#002b36" },
      separator_selected = { guifg = "#073642" },
      background = { guifg = "#657b83", guibg = "#002b36" },
      buffer_selected = { guifg = "#fdf6e3", gui = "bold" },
      fill = { guibg = "#073642" },
    },
  },
  config = function(_, opts)
    vim.api.nvim_create_user_command("BufferLineClose", function(buffer_line_opts)
      local bufnr = 1 * buffer_line_opts.args
      local buf_is_modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })

      local bdelete_arg
      if bufnr == 0 then
        bdelete_arg = ""
      else
        bdelete_arg = " " .. bufnr
      end
      local command = "bdelete!" .. bdelete_arg
      if buf_is_modified then
        local option = vim.fn.confirm("File is not saved. Close anyway?", "&Yes\n&No", 2)
        if option == 1 then
          vim.cmd(command)
        end
      else
        vim.cmd(command)
      end
    end, { nargs = 1 })
    require("bufferline").setup(opts)
  end,
  keys = {
    {
      "<C-]>",
      "<Cmd>BufferLineCycleNext<CR>",
      desc = "next buffer",
      silent = true,
      noremap = true,
    },
    {
      "<C-[>",
      "<Cmd>BufferLineCyclePrev<CR>",
      desc = "prev buffer",
      silent = true,
      noremap = true,
    },
    {
      "<C-\\>",
      "<Cmd>bdelete!<CR>",
      desc = "close buffer",
      silent = true,
      noremap = true,
    },
    {
      "<leader>bo",
      "<Cmd>BufferLineCloseOthers<CR>",
      desc = "close Others",
      silent = true,
      noremap = true,
    },
  },
}
config["which-key"] = {
  "folke/which-key.nvim",
  -- event = "User KkLoad",
  event = "VeryLazy",
  opts = {
    plugins = {
      marks = true,
      registers = true,
      spelling = { enabled = false },
      presets = {
        operators = false,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    window = {
      border = "none",
      position = "bottom",
      -- Leave 1 line at top / bottom for bufferline / lualine
      margin = { 1, 0, 1, 0 },
      padding = { 1, 0, 1, 0 },
      winblend = 0,
      zindex = 1000,
    },
  },
  config = function(_, opts)
    require("which-key").setup(opts)
    local wk = require("which-key")
    wk.register(Kk.keymap.prefix)
  end,
}

config.colorizer = {
  "norcalli/nvim-colorizer.lua",
  main = "colorizer",
  event = "User KkLoad",
  opts = {
    filetypes = { "*", css = { names = true } },
    user_default_options = {
      css = true,
      css_fn = true,
      names = false,
      always_update = true,
    },
  },
}
config.comment = {
  "numToStr/Comment.nvim",
  main = "Comment",
  opts = { mappings = { basic = true, extra = true, extended = false } },
  config = function(_, opts)
    require("Comment").setup(opts)

    -- Remove the keymap defined by Comment.nvim
    vim.keymap.del("n", "gcc")
    vim.keymap.del("n", "gbc")
    vim.keymap.del("n", "gc")
    vim.keymap.del("n", "gb")
    vim.keymap.del("x", "gc")
    vim.keymap.del("x", "gb")
    vim.keymap.del("n", "gcO")
    vim.keymap.del("n", "gco")
    vim.keymap.del("n", "gcA")
  end,
  keys = function()
    local vvar = vim.api.nvim_get_vvar

    local toggle_current_line = function()
      if vvar("count") == 0 then
        return "<Plug>(comment_toggle_linewise_current)"
      else
        return "<Plug>(comment_toggle_linewise_count)"
      end
    end

    local toggle_current_block = function()
      if vvar("count") == 0 then
        return "<Plug>(comment_toggle_blockwise_current)"
      else
        return "<Plug>(comment_toggle_blockwise_count)"
      end
    end

    local comment_below = function()
      require("Comment.api").insert.linewise.below()
    end

    local comment_above = function()
      require("Comment.api").insert.linewise.above()
    end

    local comment_eol = function()
      require("Comment.api").locked("insert.linewise.eol")()
    end

    return {
      {
        "<leader>cl",
        "<Plug>(comment_toggle_linewise)",
        desc = "comment toggle linewise",
      },
      {
        "<leader>ca",
        "<Plug>(comment_toggle_blockwise)",
        desc = "comment toggle blockwise",
      },
      {
        "<leader>cc",
        toggle_current_line,
        expr = true,
        desc = "comment toggle current line",
      },
      {
        "<leader>cb",
        toggle_current_block,
        expr = true,
        desc = "comment toggle current block",
      },
      {
        "<leader>cc",
        "<Plug>(comment_toggle_linewise_visual)",
        mode = "x",
        desc = "comment toggle linewise",
      },
      {
        "<leader>cb",
        "<Plug>(comment_toggle_blockwise_visual)",
        mode = "x",
        desc = "comment toggle blockwise",
      },
      { "<leader>co", comment_below, desc = "comment insert below" },
      { "<leader>cO", comment_above, desc = "comment insert above" },
      { "<leader>cA", comment_eol, desc = "comment insert end of line" },
    }
  end,
}
config.dashboard = {
  "nvimdev/dashboard-nvim",
  lazy = false,
  keys = {
    {
      "<leader>gd",
      function()
        vim.cmd("Dashboard")
      end,
      desc = "Go Dashboard",
      silent = true,
      noremap = true,
    },
  },
  opts = {
    theme = "doom",
    config = {
      -- https://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=Kknvim
      header = {
        " ",
        "██╗  ██╗██╗  ██╗███╗   ██╗██╗   ██╗██╗███╗   ███╗",
        "██║ ██╔╝██║ ██╔╝████╗  ██║██║   ██║██║████╗ ████║",
        "█████╔╝ █████╔╝ ██╔██╗ ██║██║   ██║██║██╔████╔██║",
        "██╔═██╗ ██╔═██╗ ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "██║  ██╗██║  ██╗██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
        " ",
        string.format(
          "Nvim: v%s   KkNvim: v%s  Colorscheme: %s",
          require("core.utils").version,
          "0.0.0",
          require("plugins.utils").get_colorscheme()
        ),
        " ",
      },
      center = {

        {
          action = "Telescope neovim-project discover",
          desc = " Find Project",
          icon = " ",
          key = "p",
        },
        {
          action = "Telescope find_files",
          desc = " Find File",
          icon = " ",
          key = "f",
        },
        {
          action = "Telescope neovim-project history ",
          desc = " Recent Projects",
          icon = " ",
          key = "rp",
        },
        {
          action = "Telescope oldfiles",
          desc = " Recent Files",
          icon = " ",
          key = "rf",
        },
        {
          action = "NeovimProjectLoadRecent",
          desc = " Last Session",
          icon = " ",
          key = "s",
        },
        {
          action = function()
            vim.cmd([[
                            function! CreateNewBuffer()
                                enew  
                                execute 'doautocmd BufEnter' bufnr('%')  
                            endfunction
                            call CreateNewBuffer()
                        ]])
          end,
          desc = " New File",
          icon = " ",
          key = "n",
        },
        {
          action = "Telescope live_grep",
          desc = " Find Text",
          icon = " ",
          key = "g",
        },
        {
          action = function()
            require("telescope.builtin").find_files({ cwd = config_root })
          end,
          desc = " Config",
          icon = " ",
          key = "c",
        },

        { icon = "  ", desc = "Mason", action = "Mason", key = "m" },
        { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },

        {
          icon = "  ",
          desc = "Edit preferences   ",
          action = string.format("edit %s/lua/custom/init.lua", config_root),
          key = "e",
        },
        {
          icon = "  ",
          desc = "About KkNvim",
          action = "lua require('plugins.utils').about()",
          key = "a",
        },
        {
          action = function()
            vim.api.nvim_input("<cmd>qa<cr>")
          end,
          desc = " Quit",
          icon = " ",
          key = "q",
        },
      },
      footer = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        return {
          "⚡ KkNvim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
          " ",
          "Hope that you enjoy using KkNvim",
        }
      end,
    },
  },
  config = function(_, opts)
    require("dashboard").setup(opts)
  end,
}
config.nui = { "MunifTanjim/nui.nvim", lazy = true }
config["flutter-tools"] = {
  "akinsho/flutter-tools.nvim",
  ft = "dart",
  dependencies = { "nvim-lua/plenary.nvim", "stevearc/dressing.nvim" },
  main = "flutter-tools",
  opts = {
    ui = { border = "rounded", notification_style = "nvim-notify" },
    decorations = { statusline = { app_version = true, device = true } },
    lsp = {
      on_attach = function(_, bufnr)
        Kk.lsp.keyAttach(bufnr)
      end,
    },
  },
}

config.gitsigns = {
  "lewis6991/gitsigns.nvim",
  event = "User KkLoad",
  main = "gitsigns",
  opts = {
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
  },
  keys = {
    {
      "<leader>gn",
      "<Cmd>Gitsigns next_hunk<CR>",
      desc = "Next hunk",
      silent = true,
      noremap = true,
    },
    {
      "<leader>gp",
      "<Cmd>Gitsigns prev_hunk<CR>",
      desc = "Prev hunk",
      silent = true,
      noremap = true,
    },
    {
      "<leader>gP",
      "<Cmd>Gitsigns preview_hunk<CR>",
      desc = "Preview hunk",
      silent = true,
      noremap = true,
    },
    {
      "<leader>gs",
      "<Cmd>Gitsigns stage_hunk<CR>",
      desc = "Stage hunk",
      silent = true,
      noremap = true,
    },
    {
      "<leader>gu",
      "<Cmd>Gitsigns undo_stage_hunk<CR>",
      desc = "Undo stage",
      silent = true,
      noremap = true,
    },
    {
      "<leader>gr",
      "<Cmd>Gitsigns reset_hunk<CR>",
      desc = "Reset hunk",
      silent = true,
      noremap = true,
    },
    {
      "<leader>gb",
      "<Cmd>Gitsigns stage_buffer<CR>",
      desc = "stage Buffer",
      silent = true,
      noremap = true,
    },
  },
}

config.hop = {
  "smoka7/hop.nvim",
  main = "hop",
  opts = { hint_position = 3, keys = "fjghdksltyrueiwoqpvbcnxmza" },
  keys = {
    {
      "<leader>hp",
      "<Cmd>HopWord<CR>",
      desc = "Hop word",
      silent = true,
      noremap = true,
    },
  },
}

config.flash = {
  "folke/flash.nvim",
  event = "User KkLoad",
  ---@type Flash.Config
  opts = {},
    -- stylua: ignore
    keys = {
        {
            "s",
            mode = {"n", "x", "o"},
            function() require("flash").jump() end,
            desc = "Flash"
        },
        {
            "S",
            mode = {"n", "x", "o"},
            function() require("flash").treesitter() end,
            desc = "Flash Treesitter"
        },
        {"r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash"},
        {
            "R",
            mode = {"o", "x"},
            function() require("flash").treesitter_search() end,
            desc = "Treesitter Search"
        },
        {
            "<c-s>",
            mode = {"c"},
            function() require("flash").toggle() end,
            desc = "Toggle Flash Search"
        }
    }
,
}
config["indent-blankline"] = {
  "lukas-reineke/indent-blankline.nvim",
  event = "User KkLoad",
  main = "ibl",
  opts = {
    exclude = {
      filetypes = {
        "dashboard",
        "terminal",
        "help",
        "log",
        "markdown",
        "TelescopePrompt",
        "lsp-installer",
        "lspinfo",
      },
    },
  },
}

config.lualine = {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "arkav/lualine-lsp-progress" },
  event = "User KkLoad",
  main = "lualine",
  opts = {
    options = {
      theme = "auto",
      icons_enabled = true,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = { "undotree", "diff" },
    },
    extensions = { "nvim-tree" },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff" },
      lualine_c = {
        function()
          return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        end,
        { "filename", file_status = true, path = 1 },
      },
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = { error = " ", warn = " ", info = " ", hint = " " },
        },
        "encoding",
        "filetype",
        function()
          local conform = require("conform")
          local bufnr = vim.api.nvim_get_current_buf()
          local clients = vim.lsp.get_clients({ bufnr = bufnr })
          local formatters = conform.list_formatters_for_buffer()
          local c = {}
          for _, client in pairs(clients) do
            if client.name ~= "null-ls" then
              table.insert(c, client.name)
            end
          end
          if formatters and #formatters > 0 then
            for _, formatter in ipairs(formatters) do
              table.insert(c, formatter)
            end
          end
          return table.concat(c, "|")
        end,
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        {
          "filename",
          file_status = true, -- displays file status (readonly status, modified status)
          path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
        },
      },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
  },
}

config["markdown-preview"] = {
  "iamcco/markdown-preview.nvim",
  ft = "markdown",
  config = function()
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_auto_close = 0
  end,
  build = "cd app && yarn install",
  keys = {
    {
      "<leader>um",
      function()
        if vim.bo.filetype == "markdown" then
          vim.cmd("MarkdownPreviewToggle")
        end
      end,
      desc = "Markdown preview",
      silent = true,
      noremap = true,
    },
  },
}
config.neogit = {
  "NeogitOrg/neogit",
  dependencies = "nvim-lua/plenary.nvim",
  main = "neogit",
  opts = {
    disable_hint = true,
    status = { recent_commit_count = 30 },
    commit_editor = { kind = "auto", show_staged_diff = false },
  },
  keys = {
    { "<leader>gt", "<Cmd>Neogit<CR>", desc = "neogit", silent = true, noremap = true },
  },
}
config.neoscroll = {
  "karb94/neoscroll.nvim",
  main = "neoscroll",
  opts = {
    mappings = {},
    hide_cursor = true,
    stop_eof = true,
    respect_scrolloff = false,
    cursor_scrolls_alone = true,
    easing_function = "sine",
    pre_hook = nil,
    post_hook = nil,
    performance_mode = false,
  },
  keys = {
    {
      "<C-u>",
      function()
        require("neoscroll").scroll(-vim.wo.scroll, true, 250)
      end,
      desc = "scroll up",
    },
    {
      "<C-d>",
      function()
        require("neoscroll").scroll(vim.wo.scroll, true, 250)
      end,
      desc = "scroll down",
    },
  },
}
config["noice"] = {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    views = {
      cmdline_popup = {
        backend = "popup",
        relative = "editor",
        zindex = 200,
        position = {
          row = "50%", -- 40% from top of the screen. This will position it almost at the center.
        },
        win_options = {
          winhighlight = {
            Normal = "NoiceCmdlinePopup",
            FloatTitle = "NoiceCmdlinePopupTitle",
            FloatBorder = "NoiceCmdlinePopupBorder",
            IncSearch = "",
            CurSearch = "",
            Search = "",
          },
          winbar = "",
          foldenable = false,
          cursorline = false,
        },
      },
    },
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
      },
    },
    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim",
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    "rcarriga/nvim-notify",
  },
}

config["nvim-autopairs"] = {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  main = "nvim-autopairs",
  config = function()
    local autopairs = require("nvim-autopairs")
    autopairs.setup({ disable_filetype = { "TelescopePrompt", "vim" } })
  end,
}

config["nvim-notify"] = {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  opts = { timeout = 3000, background_colour = "#000000", stages = "static" },
  config = function(_, opts)
    ---@diagnostic disable-next-line: undefined-field
    require("notify").setup(opts)
    vim.notify = require("notify")
  end,
}
config["leetcode"] = {
  "kawre/leetcode.nvim",
  build = ":TSUpdate html",
  event = "User KkLoad",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim", -- required by telescope
    "MunifTanjim/nui.nvim",
    "nvim-treesitter/nvim-treesitter",
    "rcarriga/nvim-notify",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- configuration goes here
  },
}
config["nvim-scrollview"] = {
  "dstein64/nvim-scrollview",
  event = "User KkLoad",
  main = "scrollview",
  opts = {
    excluded_filetypes = { "nvimtree" },
    current_only = true,
    winblend = 75,
    base = "right",
    column = 1,
  },
}
config["nvim-transparent"] = {
  "xiyaowong/nvim-transparent",
  opts = { extra_groups = { "NvimTreeNormal", "NvimTreeNormalNC" } },
  event = "User KkLoad",
  keys = { { "<leader>mt", require("plugins.utils").toggle_transparent, desc = "TransparentToggle" } },
  config = function(_, opts)
    local autogroup = vim.api.nvim_create_augroup("transparent", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = autogroup,
      callback = function()
        local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
        local foreground = string.format("#%06x", normal_hl.fg)
        local background = string.format("#%06x", normal_hl.bg)
        vim.api.nvim_command("highlight default KkNormal guifg=" .. foreground .. " guibg=" .. background)

        require("transparent").clear()
      end,
    })

    require("transparent").setup(opts)
    require("plugins.utils").init_transparent()
    local old_get_hl = vim.api.nvim_get_hl
    vim.api.nvim_get_hl = function(ns_id, opt)
      if opt.name == "Normal" then
        local attempt = old_get_hl(0, { name = "KkNormal" })
        if next(attempt) ~= nil then
          opt.name = "KkNormal"
        end
      end
      return old_get_hl(ns_id, opt)
    end
  end,
}
config["nvim-treesitter"] = {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "hiphish/rainbow-delimiters.nvim",
    "nvim-treesitter/nvim-treesitter-context",
  },
  lazy = (function()
    local file_name = vim.fn.expand("%:p")
    return file_name == "" or require("core.utils").file_exists(file_name)
  end)(),
  event = "BufRead",
  main = "nvim-treesitter",
  opts = {
    ensure_installed = {
      "c",
      "c_sharp",
      "cpp",
      "css",
      "fish",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "php",
      "python",
      "query",
      "rust",
      "typescript",
      "tsx",
      "swift",
      "toml",
      "vim",
      "vimdoc",
      "yaml",
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
      disable = function(_, buf)
        local max_filesize = 100 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>",
        node_incremental = "<CR>",
        node_decremental = "<BS>",
        scope_incremental = "<TAB>",
      },
    },
    indent = {
      enable = true,
      -- conflicts with flutter-tools.nvim, causing performance issues
      disable = { "dart" },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.install").prefer_git = true
    require("nvim-treesitter.configs").setup(opts)

    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt.foldenable = false

    local rainbow_delimiters = require("rainbow-delimiters")

    vim.g.rainbow_delimiters = {
      strategy = {
        [""] = rainbow_delimiters.strategy["global"],
        vim = rainbow_delimiters.strategy["local"],
      },
      query = { [""] = "rainbow-delimiters", lua = "rainbow-blocks" },
      highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
    }
  end,
}
config["rust-tools"] = {
  "simrat39/rust-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  ft = "rust",
  main = "rust-tools",
  event = "User KkLoad",
  opts = { server = {
    on_attach = function(_, bufnr)
      Kk.lsp.keyAttach(bufnr)
    end,
  } },
}
config.surround = {
  "kylechui/nvim-surround",
  version = "*",
  opts = {},
  event = "User KkLoad",
}
config.telescope = {
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-lua/plenary.nvim",
    "smartpde/telescope-recent-files",
    "nvim-telescope/telescope-ui-select.nvim",
    "LinArcX/telescope-env.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && "
        .. "cmake --build build --config Release && "
        .. "cmake --install build --prefix build",
    },
  },
  opts = {
    defaults = {
      initial_mode = "insert",
      mappings = {
        i = {
          ["<C-y>"] = "select_default",
          ["<C-n>"] = "move_selection_next",
          ["<C-p>"] = "move_selection_previous",
          ["<C-j>"] = "cycle_history_next",
          ["<C-k>"] = "cycle_history_prev",
          ["<C-c>"] = "close",
          ["<C-u>"] = "preview_scrolling_up",
          ["<C-d>"] = "preview_scrolling_down",
        },
      },
    },
    pickers = { find_files = { winblend = 20 } },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    local themes = require("telescope.themes")
    local fb_actions = require("telescope").extensions.file_browser.actions
    local extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
      ["ui-select"] = { themes.get_dropdown({}) },
      recent_files = { show_current_file = true, only_cwd = true },
      file_browser = {
        theme = "dropdown",
        -- disables netrw and use telescope-file-browser in its place
        hijack_netrw = false,
        mappings = {
          -- your custom insert mode mappings
          ["i"] = {
            ["<C-w>"] = function()
              vim.cmd("normal vbd")
            end,
          },
          ["n"] = {
            -- your custom normal mode mappings
            ["N"] = fb_actions.create,
            ["h"] = fb_actions.goto_parent_dir,
            ["/"] = function()
              vim.cmd("startinsert")
            end,
          },
        },
      },
    }
    opts.extensions = extensions
    telescope.setup(opts)
    telescope.load_extension("fzf")
    telescope.load_extension("env")
    telescope.load_extension("file_browser")
    telescope.load_extension("recent_files")
    telescope.load_extension("ui-select")
  end,
  keys = {
    {
      "<leader>tf",
      "<Cmd>Telescope find_files<CR>",
      desc = "Find file",
      silent = true,
      noremap = true,
    },
    {
      "<leader>tl",
      "<Cmd>Telescope live_grep<CR>",
      desc = "Live grep",
      silent = true,
      noremap = true,
    },
    {
      "<leader>te",
      "<Cmd>Telescope env<CR>",
      desc = "Environment variables",
      silent = true,
      noremap = true,
    },
    {
      "<leader>th",
      "<Cmd>Telescope help_tags<CR>",
      desc = "search Help",
      silent = true,
      noremap = true,
    },
    {
      "<C-e>",
      "<Cmd>lua require('telescope').extensions.recent_files.pick()<CR>",
      desc = "Recent files",
      silent = true,
      noremap = true,
    },
    {
      "<leader>tr",
      "<Cmd>lua require('telescope').extensions.recent_files.pick()<CR>",
      desc = "Recent files",
      silent = true,
      noremap = true,
    },
    {
      "<leader>tk",
      "<Cmd>Telescope keymaps<CR>",
      desc = "search Keymaps",
      silent = true,
      noremap = true,
    },
    {
      "<leader>tt",
      "<Cmd>Telescope<CR>",
      desc = "Telescope",
      silent = true,
      noremap = true,
    },
    {
      "<leader>tw",
      "<Cmd>Telescope grep_string<CR>",
      desc = "search current Word",
      silent = true,
      noremap = true,
    },
    {
      "<leader>td",
      "<Cmd>Telescope diagnostics()<CR>",
      desc = "search [D]iagnostics",
      silent = true,
      noremap = true,
    },
    {
      "<leader>t1",
      "<Cmd>Telescope resume<CR>",
      desc = "search Resume",
      silent = true,
      noremap = true,
    },
    {
      "<leader>to",
      "<Cmd>Telescope oldfiles<CR>",
      desc = "search Old files",
      silent = true,
      noremap = true,
    },
    {
      "<leader>tb",
      "<Cmd>Telescope buffers<CR>",
      desc = "find existing Buffers",
      silent = true,
      noremap = true,
    },
    {
      "<leader>t/",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 20,
          previewer = false,
        }))
      end,
      desc = "[/] Fuzzily search in current buffer",
      silent = true,
      noremap = true,
    },
    {
      "<leader>ts/",
      function()
        require("telescope.builtin").live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end,
      desc = "[S]earch [/] in Open Files",
      silent = true,
      noremap = true,
    },
    {
      "<leader>tc",
      function()
        require("telescope.builtin").find_files({ cwd = config_root })
      end,
      desc = "Search Neovim config",
      silent = true,
      noremap = true,
    },
    {
      "<leader>tb",
      function()
        require("telescope").extensions.file_browser.file_browser({
          path = "%:p:h",
          cwd = telescope_buffer_dir(),
          respect_gitignore = false,
          hidden = true,
          grouped = true,
          previewer = false,
          initial_mode = "normal",
          layout_config = { height = 40 },
        })
      end,
      desc = "File Browser",
      silent = true,
      noremap = true,
    },
  },
}
config["todo-comments"] = {
  "folke/todo-comments.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  main = "todo-comments",
  keys = {
    {
      "<leader>ut",
      "<Cmd>TodoTelescope<CR>",
      desc = "todo list",
      silent = true,
      noremap = true,
    },
  },
  opts = {
    {
      signs = false, -- show icons in the signs column
      sign_priority = 8, -- sign priority
      keywords = {
        FIX = {
          icon = " ", -- icon used for the sign, and in search results
          color = "error", -- can be a hex color, or a named color (see below)
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = {
          icon = "⏲ ",
          color = "test",
          alt = { "TESTING", "PASSED", "FAILED" },
        },
      },
      gui_style = {
        fg = "NONE", -- The gui style to use for the fg highlight group.
        bg = "BOLD", -- The gui style to use for the bg highlight group.
      },
      merge_keywords = true, -- when true, custom keywords will be merged with the defaults
      highlight = {
        multiline = true, -- enable multine todo comments
        multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
        multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
        before = "", -- "fg" or "bg" or empty
        keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
        after = "fg", -- "fg" or "bg" or empty
        pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
        comments_only = true, -- uses treesitter to match keywords in comments only
        max_line_len = 400, -- ignore lines longer than this
        exclude = {}, -- list of file types to exclude highlighting
      },
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" },
        test = { "Identifier", "#FF00FF" },
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        pattern = [[\b(KEYWORDS):]], -- ripgrep regex
      },
    },
  },
}

config.trouble = {
  "folke/trouble.nvim",
  opts = {}, -- for default options, refer to the configuration section for custom setup.
  cmd = "Trouble",
  keys = {
    {
      "<leader>wd",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>wb",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>ws",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>wl",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
    {
      "<leader>wL",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location List (Trouble)",
    },
    {
      "<leader>wq",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix List (Trouble)",
    },
  },
}
config.undotree = {
  "mbbill/undotree",
  config = function()
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_TreeNodeShape = "-"
  end,
  keys = {
    {
      "<leader>uu",
      "<Cmd>UndotreeToggle<CR>",
      desc = "undo tree toggle",
      silent = true,
      noremap = true,
    },
  },
}
config["zen-mode"] = {
  "folke/zen-mode.nvim",

  priority = priority.HIGH,
  opts = {
    window = {
      backdrop = 0.8,
      width = vim.fn.winwidth(0) - 16,
      height = vim.fn.winheight(0) + 1,
    },
    on_open = function()
      vim.opt.cmdheight = 1
    end,
    on_close = function()
      vim.opt.cmdheight = 2
    end,
  },
  config = function(_, opts)
    vim.api.nvim_command("highlight link ZenBg KkNormal")
    require("zen-mode").setup(opts)
  end,
  keys = {
    {
      "<leader>mz",
      "<Cmd>ZenMode<CR>",
      desc = "toggle zen mode",
      silent = true,
      noremap = true,
    },
  },
}
config["ayu"] = { "Luxed/ayu-vim", lazy = true }

config["github"] = { "projekt0n/github-nvim-theme", lazy = true }

config["gruvbox"] = { "ellisonleao/gruvbox.nvim", lazy = true }

config["kanagawa"] = { "rebelot/kanagawa.nvim", lazy = true }

config["nightfox"] = { "EdenEast/nightfox.nvim", lazy = true }

config["tokyonight"] = { "folke/tokyonight.nvim", lazy = true }

config["onedark"] = { "navarasu/onedark.nvim", lazy = true }
config["gruvbox-material"] = { "sainnhe/gruvbox-material", lazy = true }
config.mason = {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "j-hui/fidget.nvim",
    "folke/neodev.nvim",
    "neovim/nvim-lspconfig",
    {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      config = function()
        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
          "stylua", -- Used to format Lua code
        })
        ensure_installed = ensure_installed
      end,
    },
  },
  opts = {
    ensure_installed = {
      "lua_ls",
      "biome",
      "gopls",
      "tailwindcss",
      "dockerls",
      "tsserver",
      "bashls",
      "cssls",
      "html",
      "jsonls",
      "yamlls",
    },
    handlers = {
      function(server_name)
        local server = Kk.lsp["server-config"][server_name] or {}
        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
        require("lspconfig")[server_name].setup(server)
      end,
    },
  },
  event = "User KkLoad",
  cmd = "Mason",
  config = function()
    require("mason").setup({
      ui = {
        icons = {
          package_installed = symbols.Affirmative,
          package_pending = symbols.Pending,
          package_uninstalled = symbols.Negative,
        },
      },
    })
    local registry = require("mason-registry")
    local function install(package)
      local s, p = pcall(registry.get_package, package)
      if s and not p:is_installed() then
        p:install()
      end
    end

    for _, package in pairs(Kk.lsp.ensure_installed) do
      if type(package) == "table" then
        for _, p in pairs(package) do
          install(p)
        end
      else
        install(package)
      end
    end

    local lspconfig = require("lspconfig")

    for _, lsp in pairs(Kk.lsp.servers) do
      if lspconfig[lsp] ~= nil then
        local predefined_config = Kk.lsp["server-config"][lsp]
        if not predefined_config then
          predefined_config = Kk.lsp["server-config"].default
        end
        lspconfig[lsp].setup(predefined_config())
      end
    end
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      update_in_insert = true,
    })
    local signs = {
      Error = symbols.Error,
      Warn = symbols.Warn,
      Hint = symbols.Hint,
      Info = symbols.Info,
    }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
    vim.api.nvim_command("LspStart")
  end,
}

config["nvim-cmp"] = {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-vsnip",
    "saadparwaiz1/cmp_luasnip",
    "Exafunction/codeium.nvim",
    "rafamadriz/friendly-snippets",
    "onsails/lspkind.nvim",
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      dependencies = { "saadparwaiz1/cmp_luasnip" },
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load({
          paths = vim.fn.stdpath("data") .. "/lazy/friendly-snippets",
        })
        local luasnip = require("luasnip")
        luasnip.config.setup({ enable_jsregexp = true })
      end,
    },
    "nvimdev/lspsaga.nvim",
  },
  event = { "User KkLoad" },
  config = function()
    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end
    local luasnip = require("luasnip")
    local cmp = require("cmp")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspkind = require("lspkind")
    lspkind.init({
      mode = "symbol",
      preset = "codicons",
      symbol_map = {
        Text = symbols.Text,
        Method = symbols.Method,
        Function = symbols.Function,
        Constructor = symbols.Constructor,
        Field = symbols.Field,
        Variable = symbols.Variable,
        Class = symbols.Class,
        Interface = symbols.Interface,
        Module = symbols.Module,
        Property = symbols.Property,
        Unit = symbols.Unit,
        Value = symbols.Value,
        Enum = symbols.Enum,
        Keyword = symbols.Keyword,
        Snippet = symbols.Snippet,
        Color = symbols.Color,
        File = symbols.File,
        Reference = symbols.Reference,
        Folder = symbols.Folder,
        EnumMember = symbols.EnumMember,
        Constant = symbols.Constant,
        Struct = symbols.Struct,
        Event = symbols.Event,
        Operator = symbols.Operator,
        TypeParameter = symbols.TypeParameter,
      },
    })
    local sources = cmp.config.sources({
      { name = "codeium" },
      {
        name = "nvim_lsp",
        menu = "[LSP]",
        entry_filter = function(entry)
          return require("cmp").lsp.CompletionItemKind.Snippet ~= entry:get_kind()
        end,
      }, -- For nvim-lsp
      { name = "luasnip", menu = "[Snip]" }, -- For luasnip user
      { name = "buffer", menu = "[Buf]" }, -- For buffer word completion
      { name = "path", menu = "[Path]" }, -- For path completion
      { name = "cmdline", menu = "[Cmd]" }, -- For cmdline
    })
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      -- 在输入模式下也更新提示，设置为 true 也许会影响性能
      update_in_insert = true,
    })
    local signs = { Error = "󰅙", Info = "󰋼", Hint = "󰌵", Warn = "" }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
    require("codeium").setup({})
    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      experimental = { ghost_text = true },
      sources = sources,
      mapping = Kk.lsp.keymap.cmp(cmp),
      formatting = { format = lspkind.cmp_format({ mode = "symbol", maxwidth = 50 }) },
      -- formatting = {
      --     completion = {
      --         border = {
      --             "╭", "─", "╮", "│", "╯", "─", "╰", "│"
      --         },
      --         scrollbar = "║"
      --     },
      --     documentation = {
      --         border = {
      --             "╭", "─", "╮", "│", "╯", "─", "╰", "│"
      --         },
      --         scrollbar = "║"
      --     },
      --     fields = {'abbr', 'menu'},

      --     format = function(entry, vim_item)
      --         vim_item.menu = ({
      --             nvim_lsp = '[Lsp]',
      --             luasnip = '[Luasnip]',
      --             buffer = '[File]',
      --             path = '[Path]'
      --         })[entry.source.name]
      --         return vim_item
      --     end
      -- },
    })

    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer" } },
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
    })

    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))

    require("lspsaga").setup({
      finder = { keys = { toggle_or_open = "<CR>" } },
      symbol_in_winbar = { enable = false },
      server_filetype_map = { typescript = "typescript" },
    })

    require("luasnip.loaders.from_vscode").lazy_load({})
  end,
}
config["null-ls"] = {
  "jay-babu/mason-null-ls.nvim",
  event = "User KkLoad",
  dependencies = { "nvimtools/none-ls.nvim" },
  config = function()
    require("mason-null-ls").setup({
      ensure_installed = {},
      automatic_installation = false,
      handlers = {},
    })
    require("null-ls").setup({ sources = {} })
    local null_ls = require("null-ls")
    local formatting = null_ls.builtins.formatting
    null_ls.setup({
      debug = false,
      sources = {
        formatting.shfmt,
        formatting.stylua,
        formatting.csharpier,
        formatting.prettier.with({
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
            "css",
            "scss",
            "less",
            "html",
            "json",
            "yaml",
            "graphql",
          },
          extra_filetypes = { "njk" },
          prefer_local = "node_modules/.bin",
        }),
        formatting.black,
      },
      diagnostics_format = "[#{s}] #{m}",
    })
  end,
}

config["neovim-project"] = {
  "coffebar/neovim-project",
  opts = {
    projects = { "~/IdeaProjects/*", "~/IdeaProjects/flutter/*", "~/.config/*" },
  },
  keys = {
    { "<leader>tp", ":Telescope neovim-project discover<cr>", desc = "Project" },
  },
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim" },
    { "Shatur/neovim-session-manager" },
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = "nvim-tree/nvim-web-devicons",
      keys = {
        {
          "<C-1>",
          "<Cmd>NvimTreeToggle<CR>",
          desc = "toggle nvim tree",
          silent = true,
          noremap = true,
        },
        {
          "<leader>wt",
          "<Cmd>NvimTreeToggle<CR>",
          desc = "toggle nvim Tree",
          silent = true,
          noremap = true,
        },
        {
          "<leader>gt",
          "<Cmd>NvimTreeFocus<CR>",
          desc = "focus nvim Tree",
          silent = true,
          noremap = true,
        },
      },
    },
  },
  init = function()
    vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
    require("nvim-tree").setup(nvim_tree_opts)
    vim.cmd("autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif")
  end,
  lazy = false,
  priority = priority.HIGH,
}
config["barbecue"] = {
  "utilyre/barbecue.nvim",
  name = "barbecue",
  event = "User KkLoad",
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons", -- optional dependency
  },
  opts = {
    -- configurations go here
  },
}
config.conform = {
  "stevearc/conform.nvim",
  event = "User KkLoad",
  keys = {
    {
      "<C-l>",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format by conform",
    },
    {
      "<leader>uf",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format by conform",
    },
  },
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
      }
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use a sub-list to tell conform to run *until* a formatter
      -- is found.
      -- javascript = { { "prettierd", "prettier" } },
    },
  },
}
config.hardtime = {
  "m4xshen/hardtime.nvim",
  event = "User KkLoad",
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = { disabled_filetypes = { "NvimTree", "lazy", "mason", "lua", "help" } },
}
config.mini = { -- Collection of various small independent plugins/modules
  "echasnovski/mini.nvim",
  event = "User KkLoad",
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    require("mini.ai").setup({ n_lines = 500 })

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require("mini.surround").setup()

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    local statusline = require("mini.statusline")
    -- set use_icons to true if you have a Nerd Font
    statusline.setup({ use_icons = vim.g.have_nerd_font })

    -- You can configure sections in the statusline by overriding their
    -- default behavior. For example, here we set the section for
    -- cursor location to LINE:COLUMN
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return "%2l:%-2v"
    end

    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}
config["nvim-ts-autotag"] = {
  "windwp/nvim-ts-autotag",
  event = "User KkLoad",
  config = function()
    require("nvim-ts-autotag").setup({})
  end,
}
config["tris203/precognition.nvim"] = {
  event = "User KkLoad",
  "tris203/precognition.nvim",
}
config["prettier"] = {
  "MunifTanjim/prettier.nvim",
  event = "User KkLoad",
  config = function()
    local status, prettier = pcall(require, "prettier")
    if not status then
      return
    end

    prettier.setup({
      bin = "prettierd",
      filetypes = {
        "css",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "scss",
        "less",
      },
    })
  end,
}
config["smartim"] = {
  "ybian/smartim",
  event = "User KkLoad",
  config = function()
    vim.g.smartim_default = "com.apple.keylayout.ABC"
  end,
}
config["vim-go"] = {
  "fatih/vim-go",
  event = "User KkLoad",
  keys = { { "gr", "<Plug>(go-referrers)" } },
  config = function()
    vim.g.go_def_mapping_enabled = 0
  end,
}

config["toggleterm"] = {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    start_in_insert = true,
    direction = "horizontal",
  },
  keys = {
    { "<C-2>", "<Cmd>ToggleTerm<CR>", slient = "true", noremap = true },
  },
}
config["vim-illuminate"] = { "RRethy/vim-illuminate", event = "User KkLoad" }
config["nvim-soil"] = {
  "javiorfo/nvim-soil",

  -- Optional for puml syntax highlighting:
  dependencies = { "javiorfo/nvim-nyctophilia" },

  lazy = true,
  ft = "plantuml",
  opts = {
    -- If you want to change default configurations

    -- If you want to use Plant UML jar version instead of the install version
    puml_jar = "/path/to/plantuml.jar",

    -- If you want to customize the image showed when running this plugin
    image = {
      darkmode = false, -- Enable or disable darkmode
      format = "png", -- Choose between png or svg

      -- This is a default implementation of using nsxiv to open the resultant image
      -- Edit the string to use your preferred app to open the image (as if it were a command line)
      -- Some examples:
      -- return "feh " .. img
      -- return "xdg-open " .. img
      execute_to_open = function(img)
        return "nsxiv -b " .. img
      end,
    },
  },
}
Kk.plugins = config

Kk.keymap.prefix = {
  ["<leader>"] = { name = "Leader" },
  ["<leader>b"] = { name = "Buffer" },
  ["<leader>c"] = { name = "Comment(Temp)" },
  ["<leader>g"] = { name = "Go to" },
  ["<leader>w"] = { name = "Window" },
  ["<leader>m"] = { name = "Mode" },
  ["<leader>h"] = { name = "Hop" },
  ["<leader>l"] = { name = "Lsp" },
  ["<leader>t"] = { name = "Telescope" },
  ["<leader>u"] = { name = "Utils" },
  ["<leader>1"] = { name = "Test Keys" },
}
