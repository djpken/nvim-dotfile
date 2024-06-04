return {
    "jay-babu/mason-null-ls.nvim",
    event = {"BufReadPre", "BufNewFile"},
    dependencies = {"jose-elias-alvarez/null-ls.nvim"},
    config = function()
        require("mason").setup()
        require("mason-null-ls").setup({
            ensure_installed = {},
            automatic_installation = false,
            handlers = {}
        })
        require("null-ls").setup({sources = {}})
    end
}
