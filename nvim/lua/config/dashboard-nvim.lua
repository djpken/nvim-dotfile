return {
    "nvimdev/dashboard-nvim",
    lazy = false, -- As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
    config = function()
        local logo =[[                                                                 
 _                  _                
| | ___   _ _ __   | | ___   _ _ __  
| |/ / | | | '_ \  | |/ / | | | '_ \ 
|   <| |_| | | | | |   <| |_| | | | |
|_|\_\\__,_|_| |_| |_|\_\\__,_|_| |_|
          ]]

        logo = string.rep("\n", 8) .. logo .. "\n\n"
        local opts = {
            theme = "doom",
            hide = {
                -- this is taken care of by lualine
                -- enabling this messes up the actual laststatus setting after loading a file
                statusline = false
            },
            config = {
                header = vim.split(logo, "\n"),
                -- stylua: ignore
                center = {
                    {
                        action = "Telescope neovim-project discover",
                        desc = " Find Project",
                        icon = " ",
                        key = "p"
                    },
                    {
                        action = "Telescope find_files",
                        desc = " Find File",
                        icon = " ",
                        key = "f"
                    },
                    {
                        action = "ene | startinsert",
                        desc = " New File",
                        icon = " ",
                        key = "n"
                    }, {
                        action = "Telescope oldfiles",
                        desc = " Recent Files",
                        icon = " ",
                        key = "r"
                    },
                    {
                        action = "Telescope live_grep",
                        desc = " Find Text",
                        icon = " ",
                        key = "g"
                    }, {
                        action = "echo 'TODO'",
                        desc = " Config",
                        icon = " ",
                        key = "c"
                    }, {
                        action = "echo 'TODO'",
                        desc = " Restore Session",
                        icon = " ",
                        key = "s"
                    },
                    {action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l"},
                    {
                        action = function()
                            vim.api.nvim_input("<cmd>qa<cr>")
                        end,
                        desc = " Quit",
                        icon = " ",
                        key = "q"
                    }
                },
                footer = function()
                    local stats = require("lazy").stats()
                    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                    return {
                        "⚡ Neovim loaded " .. stats.loaded .. "/" ..
                            stats.count .. " plugins in " .. ms .. "ms"
                    }
                end
            }
        }

        for _, button in ipairs(opts.config.center) do
            button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
            button.key_format = "  %s"
        end

        -- close Lazy and re-open when the dashboard is ready
        if vim.o.filetype == "lazy" then
            vim.cmd.close()
            vim.api.nvim_create_autocmd("User", {
                pattern = "DashboardLoaded",
                callback = function() require("lazy").show() end
            })
        end
        vim.keymap.set("n", "<A-`>", ":Dashboard<CR>", {noremap = true})
        require("dashboard").setup(opts)
    end
}
