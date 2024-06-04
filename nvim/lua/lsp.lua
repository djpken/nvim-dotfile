local on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("Format", {clear = true}),
            buffer = bufnr,
            callback = function() vim.lsp.buf.formatting_seq_sync() end
        })
    end
end
local nvim_lsp = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').default_capabilities()
nvim_lsp.tsserver.setup {
    on_attach = on_attach,
    init_options = {
        plugins = {
            {
                name = "@vue/typescript-plugin",
                location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
                languages = {"javascript", "typescript", "vue"}
            }
        }
    },
    fileTypes = {'typescript', 'typescriptreact', 'typescript.tsx'},
    cmd = {"typescript-language-server", "--stdio"}
}

nvim_lsp.lua_ls.setup({
    on_init = function(client)
        local path = client.workspace_folders[1].name
        if not vim.loop.fs_stat(path .. "/.luarc.json") and
            not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
            client.config.settings = vim.tbl_deep_extend("force", client.config
                                                             .settings, {
                Lua = {
                    runtime = {version = "LuaJIT"},
                    workspace = {
                        checkThirdParty = false,
                        library = {vim.env.VIMRUNTIME}
                    }
                }
            })

            client.notify("workspace/didChangeConfiguration",
                          {settings = client.config.settings})
        end
        return true
    end
})
