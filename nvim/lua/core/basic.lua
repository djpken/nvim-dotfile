local g = vim.g
local opt = vim.opt
local win_height = vim.fn.winheight(0)

-- MacOS meta key
g.neovide_input_macos_alt_is_meta = true

-- netrw
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- Font
g.have_nred_font = true

-- Encoding
g.encoding = "UTF-8"
opt.fileencoding = "utf-8"

-- Tab
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- UI config
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.showmode = false

-- Sarching
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Inbox
opt.clipboard = "unnamedplus" -- use system clipboard
opt.autoread = true
opt.wrap = true
opt.scrolloff = math.floor((win_height - 1) / 2)
opt.sidescrolloff = math.floor((win_height - 1) / 2)
opt.signcolumn = "yes"
opt.shiftround = true
opt.autoindent = true
opt.smartindent = true
opt.whichwrap = "<,>,[,]"
-- Allow hiding modified buffer
opt.hidden = true
opt.mouse = "a"
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.inccommand = "split"
-- Smaller updatetime
opt.updatetime = 300
-- Time to wait for a sequence of key combination
opt.timeout = true
opt.timeoutlen = 300
-- Split window from below and right
-- Avoid "hit-enter" prompts
-- Don't pass messages to |ins-completin menu|
opt.shortmess = vim.o.shortmess .. "c"
-- Maximum of 16 lines of prompt
opt.pumheight = 16
-- Always show tab line
opt.showtabline = 2
opt.nrformats = "bin,hex,alpha"

if require("core.utils").is_windows() then
	opt.shellslash = true
end

vim.cmd([[
    autocmd TermOpen * setlocal nonumber norelativenumber
]])

opt.shadafile = "NONE"
vim.api.nvim_create_autocmd("CmdlineEnter", {
	once = true,
	callback = function()
		local shada = vim.fn.stdpath("state") .. "/shada/main.shada"
		vim.o.shadafile = shada
		vim.api.nvim_command("rshada! " .. shada)
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
