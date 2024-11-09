vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

vim.keymap.set("n", "<leader>qq", "<cmd>wqa<cr>", { desc = "[q]uit" })
vim.keymap.set("n", "<leader>qQ", "<cmd>qa<cr>", { desc = "[q]uit (without saving)" })

vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { desc = "save" })
vim.keymap.set("n", "<C-q>", "<cmd>q<cr>", { desc = "close" })

vim.keymap.set("i", "<C-j>", "{}<Left>", { desc = "{" })
vim.keymap.set("i", "<C-k>", "[]<Left>", { desc = "[" })
vim.keymap.set("i", "<C-l>", "<Esc>la", { desc = "Shift right" })
vim.keymap.set("i", "<C-h>", "<Esc>i", { desc = "Shift left" })

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Wa", "wa", {})
