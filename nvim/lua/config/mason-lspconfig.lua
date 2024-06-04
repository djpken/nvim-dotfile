return {
    "williamboman/mason-lspconfig.nvim",
    config = function()
        require('mason-lspconfig').setup({
            ensure_installed = {
                'lua_ls', 'biome', 'gopls', 'tailwindcss', 'dockerls',
                'tsserver', 'bashls', 'cssls', 'html', 'jsonls', 'yamlls'
            }
        })
    end
}
