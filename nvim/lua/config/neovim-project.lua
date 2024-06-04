return {
    "coffebar/neovim-project",
    dependencies = {
        {"nvim-lua/plenary.nvim"}, {"nvim-telescope/telescope.nvim"},
        {"Shatur/neovim-session-manager"}
    },
    lazy = false,
    priority = 100,
    config = function()
        vim.opt.sessionoptions:append("globals")
        vim.keymap.set("n", "<A-p>",
                       ":Telescope neovim-project discover<cr>")
        require("neovim-project").setup({
            projects = {
                "~/IdeaProjects/*", "~/IdeaProjects/flutter/*", "~/.config/*"
            }
        })
    end
}
