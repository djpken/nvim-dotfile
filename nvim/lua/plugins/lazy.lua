-- Set up lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system {
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
    }
end
vim.opt.rtp:prepend(lazypath)

Kk.lazy = {
    performance = {
        rtp = {
            disabled_plugins = {
                "editorconfig", "gzip", "matchit", "matchparen", "netrwPlugin",
                "shada", "tarPlugin", "tohtml", "tutor", "zipPlugin"
            }
        }
    },

    ui = {
        -- a number <1 is a percentage., >1 is a fixed size
        size = {width = 0.8, height = 0.8},
        wrap = true, -- wrap the lines in the ui
        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        border = "none",
        title = nil, ---@type string only works when border is not "none"
        title_pos = "center", ---@type "center" | "left" | "right"
        icons = {
            cmd = " ",
            config = "",
            event = "",
            ft = " ",
            init = " ",
            import = " ",
            keys = " ",
            lazy = "󰒲 ",
            loaded = "●",
            not_loaded = "○",
            plugin = " ",
            runtime = " ",
            source = " ",
            start = "",
            task = "✔ ",
            list = {"●", "➜", "★", "‒"}
        }
    }
}
