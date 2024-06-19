vim.g.mapleader = " "
vim.g.mpalocalleader = " "
-- Open the current html file with the default browser.
--
-- FIX: the function currently assumes that the user is using Windows / Linux / MacOS, which is why the command for
-- opening file only includes explorer / xdg-open / open. This should probably be changed in the future, but given that
-- I have only Windows / Linux devices at hand, this fix will have to wait.
local function open_html_file()
  if vim.bo.filetype == "html" then
    local utils = require("core.utils")
    local command
    if utils.is_linux() or utils.is_wsl() then
      command = "xdg-open"
    elseif utils.is_windows() then
      command = "explorer"
    else
      command = "open"
    end
    if require("core.utils").is_windows() then
      local old_shellslash = vim.opt.shellslash
      vim.opt.shellslash = false
      vim.api.nvim_command(string.format('silent exec "!%s %%:p"', command))
      vim.opt.shellslash = old_shellslash
    else
      vim.api.nvim_command(string.format("silent exec \"!%s '%%:p'\"", command))
    end
  end
end
LastKeyMap = nil

-- 定义一个函数来执行上一个键映射
function ExecuteLastKeyMap()
  if LastKeyMap then
    vim.api.nvim_feedkeys(LastKeyMap, "n", true)
  else
    print("No previous keymap found.")
  end
end

-- When evoked under normal / insert / visual mode, call vim's `undo` command and then go to normal mode.
local function undo()
  local mode = vim.api.nvim_get_mode().mode

  -- Only undo in normal / insert / visual mode
  if mode == "n" or mode == "i" or mode == "v" then
    vim.cmd("undo")
    -- Back to normal mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end
end

local function select()
  if vim.fn.pumvisible() == 1 then
    print("pumvisible")
    return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
  else
    print("not pumvisible")
    return vim.api.nvim_replace_termcodes("<Enter>", true, true, true)
  end
end

Kk.keymap = {}
Kk.keymap.general = {
  -- See `:h quote_`
  black_hole_register = { { "n", "v" }, "\\", '"_' },
  clear_cmd_line = { { "n", "i", "v", "t" }, "<C-g>", "<Cmd>mode<CR>", {
    noremap = true,
  } },
  cmd_forward = { "c", "<C-f>", "<Right>", { silent = false } },
  cmd_backward = { "c", "<C-b>", "<Left>", { silent = false } },
  cmd_home = { "c", "<C-a>", "<Home>", { silent = false } },
  cmd_end = { "c", "<C-e>", "<End>", { silent = false } },
  cmd_word_forward = { "c", "<A-f>", "<S-Right>", { silent = false } },
  cmd_word_backward = { "c", "<A-b>", "<S-Left>", { silent = false } },
  join_lines = {
    { "n", "v" },
    "J",
    function()
      local v_count = vim.v.count1 + 1
      local mode = vim.api.nvim_get_mode().mode
      local keys
      if mode == "n" then
        keys = v_count .. "J"
      else
        keys = "J"
      end
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
    end,
  }, -- Move the cursor through wrapped lines with j and k
  -- https://github.com/NvChad/NvChad/blob/b9963e29b21a672325af5b51f1d32a9191abcdaa/lua/core/mappings.lua#L40C5-L41C99
  move_down = {
    "n",
    "j",
    'v:count || mode(1)[0:1] == "no" ? "j" : "gj"',
    { expr = true },
  },
  move_up = {
    "n",
    "k",
    'v:count || mode(1)[0:1] == "no" ? "k" : "gk"',
    { expr = true },
  },
  open_html_file = { "n", "<A-b>", open_html_file },
  open_terminal = { "n", "<C-t>", "<Cmd>split term://bash<CR>" },
  normal_mode_in_terminal = { "t", "<Esc>", "<C-\\><C-n>" },
  save_file = { { "n", "i", "v" }, "<C-s>", "<Esc>:w<CR>" },
  shift_line_left = { "v", "<", "<gv" },
  shift_line_right = { "v", ">", ">gv" },
  undo = { { "n", "i", "v", "t", "c" }, "<C-z>", undo },
  visual_line = { "n", "V", "0v$" },
  nopSpace = { { "n", "i", "v" }, "<Space>", "<Nop>" },
  nopEsc = { { "n", "i", "v" }, "<Esc>", "<Nop>" },
  ["nopC-2"] = { { "n", "i", "v" }, "<C-2>", "<Nop>" },
  ["go_top"] = { "n", "<a-k>", "<C-w>k" },
  ["go_down"] = { "n", "<a-j>", "<C-w>j" },
  ["go_right"] = { "n", "<a-l>", "<C-w>l" },
  ["go_left"] = { "n", "<a-h>", "<C-w>h" },
  ["resize_-2"] = { "n", "<a-w>", ":resize -2<CR>" },
  ["resize_+2"] = { "n", "<a-s>", ":resize +2<CR>" },
  ["vertical_resize_-2"] = { "n", "<a-d>", ":vertical resize -2<CR>" },
  ["vertical_resize_+2"] = { "n", "<a-a>", ":vertical resize +2<CR>" },
  ["pre_diagnostic_message"] = { "n", "<C-q>[", vim.diagnostic.goto_prev },
  ["next_diagnostic_message"] = { "n", "<C-q>]", vim.diagnostic.goto_next },
  ["diagnostic_open_float"] = { "n", "<C-q>e", vim.diagnostic.open_float },
  ["diagnostic_setloc_list"] = { "n", "<C-q>q", vim.diagnostic.setloclist },
  ["clean_swap_file"] = {
    "n",
    "<S-z><S-c>",
    function()
      os.execute("find ~/.local/state/nvim/swap -type f -delete")
      vim.notify("Swap files cleaned", "info")
    end,
  },
  ["exit_terminal_mode"] = { "t", "<Esc><Esc>", "<C-\\><C-n>" },
  ["exit"] = { "n", "<leader>gq", "<Cmd>q<CR>" },
  ["save_and_Exit"] = { "n", "<leader>gz", "<Cmd>wq<CR>" },
  ["select_prev"] = { "c", "<C-p>", "<Up>" },
  ["select_next"] = { "c", "<C-n>", "<down>" },
  ["select"] = { "c", "<C-y>", select, { noremap = true, expr = true, silent = true } },
}
