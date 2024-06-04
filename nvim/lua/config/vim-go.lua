return {
    'fatih/vim-go',
    config = function()
        vim.keymap.set('n', 'gr', '<Plug>(go-referrers)')
    end
}
