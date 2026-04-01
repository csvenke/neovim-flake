local smartsplits = require("smart-splits")
local workspace = require("config.lib.workspace")

smartsplits.setup({
  ignored_buftypes = {
    "nofile",
    "quickfix",
    "prompt",
  },
  ignored_filetypes = {
    "no-neck-pain",
  },
  default_amount = 5,
  move_cursor_same_row = false,
})

local function smart_move_with_skip(move_fn, continue_fn)
  local current_win = vim.api.nvim_get_current_win()
  move_fn()
  local new_win = vim.api.nvim_get_current_win()

  if new_win ~= current_win and workspace.should_skip(new_win) then
    continue_fn()
  end
end

vim.keymap.set("n", "<C-k>", smartsplits.move_cursor_up, { desc = "Move up" })

vim.keymap.set("n", "<C-l>", function()
  smart_move_with_skip(smartsplits.move_cursor_right, smartsplits.move_cursor_right)
end, { desc = "Move right" })

vim.keymap.set("n", "<C-j>", smartsplits.move_cursor_down, { desc = "Move down" })

vim.keymap.set("n", "<C-h>", function()
  smart_move_with_skip(smartsplits.move_cursor_left, smartsplits.move_cursor_left)
end, { desc = "Move left" })

vim.keymap.set("n", "<M-k>", smartsplits.resize_up, { desc = "Resize up" })
vim.keymap.set("n", "<M-l>", smartsplits.resize_right, { desc = "Resize right" })
vim.keymap.set("n", "<M-j>", smartsplits.resize_down, { desc = "Resize down" })
vim.keymap.set("n", "<M-h>", smartsplits.resize_left, { desc = "Resize left" })

-- Override default movement
vim.keymap.set("n", "<C-w>k", smartsplits.move_cursor_up, { desc = "Move up" })
vim.keymap.set("n", "<C-w>l", function()
  smart_move_with_skip(smartsplits.move_cursor_right, smartsplits.move_cursor_right)
end, { desc = "Move right" })
vim.keymap.set("n", "<C-w>j", smartsplits.move_cursor_down, { desc = "Move down" })
vim.keymap.set("n", "<C-w>h", function()
  smart_move_with_skip(smartsplits.move_cursor_left, smartsplits.move_cursor_left)
end, { desc = "Move left" })

-- Override default swapping
vim.keymap.set("n", "<C-w>K", smartsplits.swap_buf_up, { desc = "Swap window up" })
vim.keymap.set("n", "<C-w>L", smartsplits.swap_buf_right, { desc = "Swap window right" })
vim.keymap.set("n", "<C-w>J", smartsplits.swap_buf_down, { desc = "Swap window down" })
vim.keymap.set("n", "<C-w>H", smartsplits.swap_buf_left, { desc = "Swap window left" })
