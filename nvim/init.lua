Kk = {}
require("core.init")
require("plugins.init")
require("v0_1")

-- require('options')
-- require('autocmds')
-- require('keymaps')
-- require('plugins')
-- require('colorscheme')

-- Load user configuration files
local config_root = string.gsub(vim.fn.stdpath("config"), "\\", "/")
if not vim.api.nvim_get_runtime_file("lua/custom/", false)[1] then
	os.execute('mkdir "' .. config_root .. '/lua/custom"')
end

local custom_path = config_root .. "/lua/custom/init.lua"
if require("core.utils").file_exists(custom_path) then
	require("custom.init")
end

-- Define keymap
local keymap = Kk.keymap.general
require("core.utils").group_map(keymap)

for filetype, config in pairs(Kk.ft) do
	require("core.utils").ft(filetype, config)
end

-- Only load plugins and colorscheme when --noplugin arg is not present
if not require("core.utils").noplugin then
	-- Load plugins
	local config = {}
	for _, plugin in pairs(Kk.plugins) do
		config[#config + 1] = plugin
	end
	require("lazy").setup(config, Kk.lazy)

	require("core.utils").group_map(Kk.keymap.plugins)

	-- Define colorscheme
	if not Kk.colorscheme then
		local colorscheme_cache = vim.fn.stdpath("data") .. "/colorscheme"
		if require("core.utils").file_exists(colorscheme_cache) then
			local colorscheme_cache_file = io.open(colorscheme_cache, "r")
			---@diagnostic disable: need-check-nil
			local colorscheme = colorscheme_cache_file:read("*a")
			colorscheme_cache_file:close()
			Kk.colorscheme = Kk.colorschemes[colorscheme]
		else
			Kk.colorscheme = Kk.colorschemes["default-dark"]
		end
	end
	
	-- Init transparent

	require("plugins.utils").colorscheme(Kk.colorscheme)
end

