---@diagnostic disable: need-check-nil
local utils = {}

utils.about = function()
    local status, popup = pcall(require, "nui.popup")
    if not status then error "nui.nvim required" end

    local line = require "nui.line"
    local width = 80

    local p = popup {
        enter = true,
        focusable = true,
        border = {
            style = "single",
            text = {
                top = "About KkNvim",
                top_align = "center",
                bottom = "Press q to close window",
                bottom_align = "center"
            }
        },
        buf_options = {modifiable = true, readonly = false},
        position = "50%",
        size = {width = tostring(width), height = "30%"}
    }

    p:mount()

    local function render(content, row)
        local l = line()
        l:append(content)
        l:render(p.bufnr, -1, row)
    end

    render("", 1)
    render("A beautiful, powerful and highly customizable neovim config.", 2)
    render("", 3)
    render("Author: KenHsu", 4)
    render("", 5)
    render("Url: https://github.com/djpken", 6)
    render("", 7)
    render(string.format("Copyright © 2024-%s KenHsu", os.date "%Y"), 8)

    p:map("n", "q", function()
        local old_buf_list = vim.api.nvim_list_bufs()
        p:unmount()
        local new_buf_list = vim.api.nvim_list_bufs()
        for key, bufnr in pairs(new_buf_list) do
            if old_buf_list[key] ~= bufnr then
                vim.api.nvim_buf_delete(bufnr, {force = true})
                break
            end
        end
    end, {noremap = true, silent = true})

    vim.api.nvim_set_option_value("modifiable", false, {buf = p.bufnr})
    vim.api.nvim_set_option_value("readonly", true, {buf = p.bufnr})
end

-- Use nui popup to check whether nerd font icons look normal
utils.check_icons = function()
    local status, popup = pcall(require, "nui.popup")
    if not status then
        error "The icon-check functionality requires nui.nvim."
    end

    local text = require "nui.text"
    local line = require "nui.line"

    local item_width = 24
    local column_number = math.floor(vim.fn.winwidth(0) / item_width) - 1
    local width = tostring(column_number * item_width)
    local win_height = vim.fn.winheight(0)

    local p = popup {
        enter = true,
        focusable = true,
        border = {
            style = "single",
            text = {
                top = "Check Nerd Font Icons",
                top_align = "center",
                bottom = "Press q to close window",
                bottom_align = "center"
            }
        },
        buf_options = {modifiable = true, readonly = false},
        position = "50%",
        size = {width = width, height = "60%"}
    }

    p:mount()

    local count = 0
    local new_line = line()
    local row
    for name, icon in require("core.utils").ordered_pair(Kk.symbols) do
        row = math.floor(count / column_number) + 1
        local index = count % column_number

        if index == 0 then
            if row ~= 1 then new_line:render(p.bufnr, -1, row - 1) end

            new_line = line()
        end

        local _name = text(name, "Type")
        local _icon = text(icon, "Label")

        new_line:append(_name)
        new_line:append(string.rep(" ", 18 - _name:width()))
        new_line:append(_icon)
        new_line:append(string.rep(" ", item_width - 18 - _icon:width()))

        count = count + 1
    end

    new_line:render(p.bufnr, -1, row)

    p:update_layout{
        size = {width = width, height = tostring(math.min(row, win_height - 2))}
    }

    p:map("n", "q", function()
        local old_buf_list = vim.api.nvim_list_bufs()
        p:unmount()
        local new_buf_list = vim.api.nvim_list_bufs()
        for key, bufnr in pairs(new_buf_list) do
            if old_buf_list[key] ~= bufnr then
                vim.api.nvim_buf_delete(bufnr, {force = true})
                break
            end
        end
    end, {noremap = true, silent = true})

    vim.api.nvim_set_option_value("modifiable", false, {buf = p.bufnr})
    vim.api.nvim_set_option_value("readonly", true, {buf = p.bufnr})
end

-- Set up colorscheme and Ice.colorscheme, but does not take care of lualine
-- The colorscheme is a table with:
--   - name: to be called with the `colorscheme` command
--   - setup: optional; can either be:
--     - a function called alongside `colorscheme`
--     - a table for plugin setup
--   - background: "light" / "dark"
--   - lualine_theme: optional
---@param colorscheme table
utils.colorscheme = function(colorscheme)
    Kk.colorscheme = colorscheme
    if type(colorscheme.setup) == "table" then
        require(colorscheme.name).setup(colorscheme.setup)
    elseif type(colorscheme.setup) == "function" then
        colorscheme.setup()
    end
    vim.cmd("colorscheme " .. colorscheme.name)
    vim.o.background = colorscheme.background

    vim.api.nvim_set_hl(0, "Visual", {reverse = true})
end

utils.get_colorscheme = function()
    local colorscheme_cache = vim.fn.stdpath "data" .. "/colorscheme"
    if require("core.utils").file_exists(colorscheme_cache) then
        local colorscheme_cache_file = io.open(colorscheme_cache, "r")
        ---@diagnostic disable: need-check-nil
        local colorscheme = colorscheme_cache_file:read "*a"
        colorscheme_cache_file:close()
        return colorscheme
    else
        return "default-dark"
    end
end

utils.init_transparent = function()
    local transparent_cache = vim.fn.stdpath("data") .. "/transparent_cache"
    local transparent_cache_file = io.open(transparent_cache, "r")
    local value = "false"
    if transparent_cache_file then
        value = transparent_cache_file:read("*a")
        transparent_cache_file:close()
    end
    -- TODO
    if value == "true" then
        vim.cmd("TransparentEnable")
    else
        vim.cmd("TransparentDisable")
    end
end
utils.toggle_transparent = function()
    local status = pcall(require, "transparent")
    if not status then return end
    local transparent_cache = vim.fn.stdpath("data") .. "/transparent_cache"
    local transparent_cache_file = io.open(transparent_cache, "r")
    local value = "false"
    if transparent_cache_file then
        value = transparent_cache_file:read("*a")
        transparent_cache_file:close()
    end

    local newValue
    if value == ("false") then
        newValue = "true"
        vim.cmd("TransparentEnable")
    else
        newValue = "false"
        vim.cmd("TransparentDisable")
    end

    -- 寫入新的值到文件
    local f = io.open(transparent_cache, "w")
    if f then
        f:write(newValue)
        f:close()
    else
        print("Error: Unable to open transparent_cache for writing.")
    end
end
-- Switch colorscheme
utils.select_colorscheme = function()
    local status, _ = pcall(require, "telescope")
    if not status then return end
    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"
    local themes = require "telescope.themes"

    local function picker(opts)
        opts = opts or {}

        local colorschemes = Kk.colorschemes
        local results = {}
        for name, _ in require("core.utils").ordered_pair(colorschemes) do
            results[#results + 1] = name
        end

        pickers.new(opts, themes.get_dropdown {
            prompt_title = "Colorschemes",
            finder = finders.new_table {
                entry_maker = function(entry)
                    return {value = entry, display = entry, ordinal = entry}
                end,
                results = results
            },
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)

                    local selection = action_state.get_selected_entry()
                    local config = colorschemes[selection.value]

                    utils.colorscheme(config)

                    local colorscheme_cache =
                        vim.fn.stdpath "data" .. "/colorscheme"
                    local f = io.open(colorscheme_cache, "w")
                    f:write(selection.value)
                    f:close()
                end)
                return true
            end
        }):find()
    end

    picker()
end

-- Checks whether a lsp client is active
---@param lsp string
---@return boolean
utils.lsp_is_active = function(lsp)
    local active_client = vim.lsp.get_clients {name = lsp}
    return #active_client > 0
end

return utils
