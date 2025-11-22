local smartsplits = require("smart-splits")

smartsplits.setup({
  ignored_buftypes = {
    "nofile",
    "quickfix",
    "prompt",
  },
  ignored_filetypes = { "NvimTree" },
  default_amount = 5,
  move_cursor_same_row = false,
})

vim.keymap.set("n", "<C-k>", smartsplits.move_cursor_up, { desc = "Move up" })
vim.keymap.set("n", "<C-l>", smartsplits.move_cursor_right, { desc = "Move right" })
vim.keymap.set("n", "<C-j>", smartsplits.move_cursor_down, { desc = "Move down" })
vim.keymap.set("n", "<C-h>", smartsplits.move_cursor_left, { desc = "Move left" })

vim.keymap.set("n", "<M-k>", smartsplits.resize_up, { desc = "Resize up" })
vim.keymap.set("n", "<M-l>", smartsplits.resize_right, { desc = "Resize right" })
vim.keymap.set("n", "<M-j>", smartsplits.resize_down, { desc = "Resize down" })
vim.keymap.set("n", "<M-h>", smartsplits.resize_left, { desc = "Resize left" })

-- Override default movement
vim.keymap.set("n", "<C-w>k", smartsplits.move_cursor_up, { desc = "Move up" })
vim.keymap.set("n", "<C-w>l", smartsplits.move_cursor_right, { desc = "Move right" })
vim.keymap.set("n", "<C-w>j", smartsplits.move_cursor_down, { desc = "Move down" })
vim.keymap.set("n", "<C-w>h", smartsplits.move_cursor_left, { desc = "Move left" })

-- Override default swapping
vim.keymap.set("n", "<C-w>K", smartsplits.swap_buf_up, { desc = "Swap window up" })
vim.keymap.set("n", "<C-w>L", smartsplits.swap_buf_right, { desc = "Swap window right" })
vim.keymap.set("n", "<C-w>J", smartsplits.swap_buf_down, { desc = "Swap window down" })
vim.keymap.set("n", "<C-w>H", smartsplits.swap_buf_left, { desc = "Swap window left" })
