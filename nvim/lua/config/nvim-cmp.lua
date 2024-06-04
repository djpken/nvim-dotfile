return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "onsails/lspkind.nvim", "hrsh7th/cmp-nvim-lsp", -- lsp auto-completion
        "hrsh7th/cmp-buffer", -- buffer auto-completion
        "hrsh7th/cmp-path", -- path auto-completion
        "hrsh7th/cmp-cmdline" -- cmdline auto-completion
    },
    config = function()
        local has_words_before = function()
            unpack = unpack or table.unpack
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and
                       vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(
                           col, col):match("%s") == nil
        end

        local luasnip = require("luasnip")
        local cmp = require("cmp")
        local lspkind = require('lspkind')
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        local sources = cmp.config.sources({
            {
                name = 'nvim_lsp',
                menu = "[LSP]",
                entry_filter = function(entry)
                    return require('cmp').lsp.CompletionItemKind.Snippet ~=
                               entry:get_kind()

                end
            }, -- For nvim-lsp
            {name = 'luasnip', menu = "[Snip]"}, -- For luasnip user
            {name = 'buffer', menu = "[Buf]"}, -- For buffer word completion
            {name = 'path', menu = "[Path]"}, -- For path completion
            {name = 'cmdline', menu = "[Cmd]"} -- For cmdline
        })
        local mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-k>'] = cmp.mapping.select_prev_item(),
            ['<C-j>'] = cmp.mapping.select_next_item(),
            ['<CR>'] = cmp.mapping.confirm({
                select = true,
                behavior = cmp.ConfirmBehavior.Replace
            }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end, {"i", "s"}), -- i - insert mode; s - select mode
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, {"i", "s"})
        })

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end
            },
            experimental = {ghost_text = true},
            mapping = mapping,
            formatting = {
                fields = {'abbr', 'menu'},
                format = function(entry, vim_item)
                    vim_item.menu = ({
                        nvim_lsp = '[Lsp]',
                        luasnip = '[Luasnip]',
                        buffer = '[File]',
                        path = '[Path]'
                    })[entry.source.name]
                    return vim_item
                end
            },
            sources = sources

        })
    end
}
