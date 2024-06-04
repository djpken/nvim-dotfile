return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function()

        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        vim.opt.termguicolors = true
        vim.keymap.set("n", "<A-1>", ":NvimTreeToggle<CR>", {noremap = true})
        local function on_attach(bufnr)
            local api = require "nvim-tree.api"

            local function opts(desc)
                return {
                    desc = "nvim-tree: " .. desc,
                    buffer = bufnr,
                    noremap = true,
                    silent = true,
                    nowait = true
                }
            end
            api.config.mappings.default_on_attach(bufnr)
            vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
        end

        require("nvim-tree").setup({
            on_attach = on_attach,
            sort = {sorter = "case_sensitive"},
            view = {width = 30},
            renderer = {group_empty = true},
            filters = {dotfiles = false}
        })
    end
}
