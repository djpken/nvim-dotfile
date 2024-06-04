if vim.fn.has('termguicolors') == 1 then vim.opt.termguicolors = true end
vim.opt.background = 'dark'
vim.g.gruvbox_material_enable_italic = true
vim.g.gruvbox_material_background = 'soft'
vim.cmd.colorscheme('gruvbox-material')
local symbols = require('trouble').statusline({
    mode = "lsp_document_symbols",
    groups = {},
    title = false,
    filter = {range = true},
    format = "{kind_icon}{symbol.name:Normal}",
    -- The following line is needed to fix the background color
    -- Set it to the lualine section you want to use
    hl_group = "lualine_c_normal"
})
local clients_lsp = function()
    local bufnr = vim.api.nvim_get_current_buf()

    local clients = vim.lsp.buf_get_clients(bufnr)
    if next(clients) == nil then return '' end

    local c = {}
    for _, client in pairs(clients) do table.insert(c, client.name) end
    return '\u{f085} ' .. table.concat(c, '|')
end
local clients_null_ls = function()
    local bufnr = vim.api.nvim_get_current_buf()

    local clients = vim.lsp.buf_get_clients(bufnr)
    if next(clients) == nil then return '' end

    local c = {}
    for _, client in pairs(clients) do table.insert(c, client.name) end
    return '\u{f085} ' .. table.concat(c, '|')
end
require('lualine').setup {
    options = {
        theme = 'gruvbox-material',
        icons_enabled = true,
        section_separators = {left = '', right = ''},
        component_separators = {left = '', right = ''},
        disabled_filetypes = {}
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch'},
        lualine_c = {
            {
                'filename',
                file_status = true, -- displays file status (readonly status, modified status)
                path = 0 -- 0 = just filename, 1 = relative path, 2 = absolute path
            }, {symbols.get, cond = symbols.has}
        },
        lualine_x = {
            {
                'diagnostics',
                sources = {"nvim_diagnostic"},
                symbols = {
                    error = ' ',
                    warn = ' ',
                    info = ' ',
                    hint = ' '
                }
            }, 'encoding', 'filetype'
        },
        lualine_y = {'clients_lsp'},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
            {
                'filename',
                file_status = true, -- displays file status (readonly status, modified status)
                path = 1 -- 0 = just filename, 1 = relative path, 2 = absolute path
            }
        },
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    },
    extensions = {'fugitive'}
}
