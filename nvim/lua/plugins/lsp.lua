local lsp = {}

lsp.keyAttach = function(bufnr)
    require("core.utils").group_map(lsp.keymap.mapLsp, {
        noremap = true,
        silent = true,
        buffer = bufnr
    })
end

lsp.disableFormat = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
end

lsp.flags = {debounce_text_changes = 150}

-- Do not configure dartls here when using flutter-tools
lsp.ensure_installed = {
    "clangd",
    "css-lsp",
    "emmet-ls",
    "html-lsp",
    "json-lsp",
    "lua-language-server",
    "omnisharp",
    "pyright",
    "black",
    "typescript-language-server",
    "csharpier",
    "fixjson",
    "prettier",
    "shfmt",
    "stylua"
}

lsp.servers = {
    "clangd",
    "cssls",
    "emmet_ls",
    "html",
    "jsonls",
    "lua_ls",
    "omnisharp",
    "pyright",
    "tsserver"
}

local config = {}

config.default = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach",
                                            {clear = true}),
        callback = function(event)
            -- NOTE: Remember that Lua is a real programming language, and as such it is possible
            -- to define small helper and utility functions so you don't have to repeat yourself.
            --
            -- In this case, we create a function that lets us more easily define mappings specific
            -- for LSP related items. It sets the mode, buffer and description for us each time.
            local map = function(keys, func, desc)
                vim.keymap.set("n", keys, func,
                               {buffer = event.buf, desc = "LSP: " .. desc})
            end

            -- Jump to the definition of the word under your cursor.
            --  This is where a variable was first declared, or where a function is defined, etc.
            --  To jump back, press <C-t>.
            map("gd", require("telescope.builtin").lsp_definitions,
                "[G]oto [D]efinition")

            -- Find references for the word under your cursor.
            map("gr", require("telescope.builtin").lsp_references,
                "[G]oto [R]eferences")

            -- Jump to the implementation of the word under your cursor.
            --  Useful when your language has ways of declaring types without an actual implementation.
            map("gI", require("telescope.builtin").lsp_implementations,
                "[G]oto [I]mplementation")

            -- Jump to the type of the word under your cursor.
            --  Useful when you're not sure what type a variable is and you want to see
            --  the definition of its *type*, not where it was *defined*.
            map("<leader>D", require("telescope.builtin").lsp_type_definitions,
                "Type [D]efinition")

            -- Fuzzy find all the symbols in your current document.
            --  Symbols are things like variables, functions, types, etc.
            map("<leader>ds", require("telescope.builtin").lsp_document_symbols,
                "[D]ocument [S]ymbols")

            -- Fuzzy find all the symbols in your current workspace.
            --  Similar to document symbols, except searches over your entire project.
            map("<leader>ws",
                require("telescope.builtin").lsp_dynamic_workspace_symbols,
                "[W]orkspace [S]ymbols")

            -- Rename the variable under your cursor.
            --  Most Language Servers support renaming across files, etc.
            map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

            -- Execute a code action, usually your cursor needs to be on top of an error
            -- or a suggestion from your LSP for this to activate.
            map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

            -- Opens a popup that displays documentation about the word under your cursor
            --  See `:help K` for why this keymap.
            map("K", vim.lsp.buf.hover, "Hover Documentation")

            -- WARN: This is not Goto Definition, this is Goto Declaration.
            --  For example, in C this would take you to the header.
            map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

            -- The following two autocommands are used to highlight references of the
            -- word under your cursor when your cursor rests there for a little while.
            --    See `:help CursorHold` for information about when this is executed
            --
            -- When you move your cursor, the highlights will be cleared (the second autocommand).
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client.server_capabilities.documentHighlightProvider then
                local highlight_augroup =
                    vim.api.nvim_create_augroup("kickstart-lsp-highlight",
                                                {clear = false})
                vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
                    buffer = event.buf,
                    group = highlight_augroup,
                    callback = vim.lsp.buf.document_highlight
                })

                vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
                    buffer = event.buf,
                    group = highlight_augroup,
                    callback = vim.lsp.buf.clear_references
                })

                vim.api.nvim_create_autocmd("LspDetach", {
                    group = vim.api.nvim_create_augroup("kickstart-lsp-detach",
                                                        {clear = true}),
                    callback = function(event2)
                        vim.lsp.buf.clear_references()
                        vim.api.nvim_clear_autocmds({
                            group = "kickstart-lsp-highlight",
                            buffer = event2.buf
                        })
                    end
                })
            end

            -- The following autocommand is used to enable inlay hints in your
            -- code, if the language server you are using supports them
            --
            -- This may be unwanted, since they displace some of your code
            if client and client.server_capabilities.inlayHintProvider and
                vim.lsp.inlay_hint then
                map("<leader>12", function()
                    vim.lsp.inlay_hint
                        .enable(not vim.lsp.inlay_hint.is_enabled())
                end, "[T]oggle Inlay [H]ints")
            end
        end
    })
    return {

        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        flags = lsp.flags,
        on_attach = function(client, bufnr)
            lsp.disableFormat(client)
            lsp.keyAttach(bufnr)
        end
    }
end

config.cssls = function()

    return vim.tbl_extend("force", config.default(), {
        settings = {
            css = {validate = true, lint = {unknownAtRules = "ignore"}},
            less = {validate = true, lint = {unknownAtRules = "ignore"}},
            scss = {validate = true, lint = {unknownAtRules = "ignore"}}
        }
    })
end

config.emmet_ls = function()
    return {
        filetypes = {
            "html",
            "typescriptreact",
            "javascriptreact",
            "css",
            "sass",
            "scss",
            "less"
        }
    }
end

config.lua_ls = function()
    local runtime_path = vim.split(package.path, ";")
    table.insert(runtime_path, "lua/?.lua")
    table.insert(runtime_path, "lua/?/init.lua")
    return vim.tbl_extend("force", config.default(), {
        settings = {
            Lua = {
                runtime = {version = "LuaJIT", path = runtime_path},
                diagnostics = {globals = {"vim"}},
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false
                },
                telemetry = {enable = false}
            }
        }
    })
end

config.omnisharp = function()
    return vim.tbl_extend("force", config.default(), {
        cmd = {
            "dotnet",
            vim.fn.stdpath("data") ..
                "/mason/packages/omnisharp/libexec/Omnisharp.dll"
        },
        on_attach = function(client, bufnr)
            client.server_capabilities.semanticTokensProvider = nil
            config.default().on_attach(client, bufnr)
        end,
        enable_editorconfig_support = true,
        enable_ms_build_load_projects_on_demand = false,
        enable_roslyn_analyzers = false,
        organize_imports_on_format = false,
        enable_import_completion = false,
        sdk_include_prereleases = true,
        analyze_open_documents_only = false
    })
end

config.tsserver = function()
    return {
        init_options = {
            plugins = {
                {
                    name = "@vue/typescript-plugin",
                    location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
                    languages = {"javascript", "typescript", "vue"}
                }
            }
        },
        single_file_support = true,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        fileTypes = {"typescript", "typescriptreact", "typescript.tsx"},
        cmd = {"typescript-language-server", "--stdio"},
        flags = lsp.flags,
        on_attach = function(client, bufnr)
            if #vim.lsp.get_clients({name = "denols"}) > 0 then
                client.stop()
            else
                lsp.disableFormat(client)
                lsp.keyAttach(bufnr)
            end
        end
    }
end

lsp["server-config"] = config

local keymap = {}

keymap.mapLsp = {
    rename = {"n", "<leader>lr", "<Cmd>Lspsaga rename<CR>"},
    code_action = {"n", "<leader>lc", "<Cmd>Lspsaga code_action<CR>"},
    go_to_definition = {"n", "<leader>ld", "<Cmd>Lspsaga goto_definition<CR>"},
    doc = {"n", "<leader>lh", "<Cmd>Lspsaga hover_doc<CR>"},
    references = {"n", "<leader>lR", "<Cmd>Lspsaga finder<CR>"},
    go_to_implementation = {"n", "<leader>li", "<Cmd>Lspsaga finder<CR>"},
    show_line_diagnostic = {
        "n",
        "<leader>lP",
        "<Cmd>Lspsaga show_line_diagnostics<CR>"
    },
    next_diagnostic = {"n", "<leader>ln", "<Cmd>Lspsaga diagnostic_jump_next<CR>"},
    prev_diagnostic = {"n", "<leader>lp", "<Cmd>Lspsaga diagnostic_jump_prev<CR>"},
    format_code = {
        "n",
        "<leader>lf",
        function()
            local lsp_is_active = require("plugins.utils").lsp_is_active

            if lsp_is_active("denols") then
                vim.cmd("<Cmd>w")
                vim.cmd("!deno fmt %")
                vim.cmd("")
                return
            end

            if lsp_is_active("rust_analyzer") then
                vim.cmd("<Cmd>w")
                vim.cmd("!cargo fmt")
                vim.cmd("")
                return
            end

            vim.lsp.buf.format({async = true})
        end
    }
}

keymap.cmp = function(cmp)
    return {
        ["<A-.>"] = cmp.mapping(cmp.mapping.complete(), {"i", "c"}),
        ["<A-,>"] = cmp.mapping({i = cmp.mapping.abort(), c = cmp.mapping
            .close()}),
        ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), {"i", "c"}),
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), {"i", "c"}),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-y>"] = cmp.mapping.confirm({
            select = true,
            behavior = cmp.ConfirmBehavior.Replace
        })
    }
end

lsp.keymap = keymap

Kk.lsp = lsp
