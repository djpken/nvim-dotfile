-- define common options
local opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
}
-----------------
-- Global --
-----------------

vim.keymap.set("n", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-----------------
-- Normal mode --
-----------------

-- Better window navigation
vim.keymap.set('n', '<leader>h', '<C-w>h', opts)
vim.keymap.set('n', '<leader>j', '<C-w>j', opts)
vim.keymap.set('n', '<leader>k', '<C-w>k', opts)
vim.keymap.set('n', '<leader>l', '<C-w>l', opts)

-- Resize with arrows
vim.keymap.set('n', '<leader><Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<leader><Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<leader><Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<leader><Right>', ':vertical resize +2<CR>', opts)

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-----------------
-- Insert mode --
-----------------

-- Vim-go
-- vim.api.nvim_set_keymap("i", "<tab>", "<C-R>=v:lua.tab_complete()<CR>" ,{silent = true, noremap = true})
-- vim.api.nvim_set_keymap("i", "<s-tab>", "<C-R>=v:lua.s_tab_complete()<CR>" ,{silent = true, noremap = true})
-- vim.api.nvim_set_keymap('i', '<enter>', '<C-R>=v:lua.enter_key()<CR>' ,{silent = true, noremap = true})

-----------------
-- Command mode --
-----------------

vim.cmd('command! Init source ~/.config/nvim/init.lua')
