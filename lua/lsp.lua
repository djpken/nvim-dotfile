require('mason').setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

require('mason-lspconfig').setup({
    ensure_installed = { 'lua_ls','gopls'},
})
local nvim_lsp = require('lspconfig')
nvim_lsp.gopls.setup{}

