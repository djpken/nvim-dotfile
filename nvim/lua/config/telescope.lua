return {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim'},
    config = function()
        local status, telescope = pcall(require, "telescope")
        if (not status) then return end
        local actions = require('telescope.actions')
        local builtin = require("telescope.builtin")
        local function telescope_buffer_dir()
            return vim.fn.expand('%:p:h')
        end
        local fb_actions = require"telescope".extensions.file_browser.actions

        telescope.setup {
            defaults = {mappings = {n = {["q"] = actions.close}}},
            extensions = {
                file_browser = {
                    theme = "dropdown",
                    -- disables netrw and use telescope-file-browser in its place
                    hijack_netrw = true,
                    mappings = {
                        -- your custom insert mode mappings
                        ["i"] = {
                            ["<C-w>"] = function()
                                vim.cmd('normal vbd')
                            end
                        },
                        ["n"] = {
                            -- your custom normal mode mappings
                            ["N"] = fb_actions.create,
                            ["h"] = fb_actions.goto_parent_dir,
                            ["/"] = function()
                                vim.cmd('startinsert')
                            end
                        }
                    }
                }
            }
        }
        local opts = {
            noremap = true,      -- non-recursive
            silent = true,       -- do not show message
        }
        telescope.load_extension("file_browser")
        vim.keymap.set('n', '<A-e>', builtin.find_files, opts)
        vim.keymap.set('n', '<A-g>', builtin.live_grep, opts)
        vim.keymap.set('n', '<A-b>', builtin.buffers, opts)
        vim.keymap.set('n', '<A-h>', builtin.help_tags, opts)
        vim.keymap.set('n', '<A-d>', builtin.diagnostics, opts)
        vim.keymap.set("n", "<A-3>", function()
            telescope.extensions.file_browser.file_browser({
                path = "%:p:h",
                cwd = telescope_buffer_dir(),
                respect_gitignore = false,
                hidden = true,
                grouped = true,
                previewer = false,
                initial_mode = "normal",
                layout_config = {height = 40}
            })
        end)
    end
}
