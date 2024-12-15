vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- quitting
vim.keymap.set("n", "<leader>qq", "<cmd>wqa<cr>", { desc = "[q]uit" })
vim.keymap.set("n", "<leader>qQ", "<cmd>qa<cr>", { desc = "[q]uit (without saving)" })
vim.keymap.set("n", "<C-q>", "<cmd>q<cr>", { desc = "[q]uit" })

-- saving
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { desc = "[s]ave" })
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Wa", "wa", {})
vim.api.nvim_create_user_command("WA", "wa", {})

vim.keymap.set("i", "<C-j>", "{}<Left>", { desc = "{" })
vim.keymap.set("i", "<C-k>", "[]<Left>", { desc = "[" })
vim.keymap.set("i", "<C-l>", "<Esc>la", { desc = "Shift right" })
vim.keymap.set("i", "<C-h>", "<Esc>i", { desc = "Shift left" })

-- quick fix list
vim.keymap.set("n", "<C-n>", "<cmd>cnext<cr>", { desc = "qf [n]ext" })
vim.keymap.set("n", "<C-p>", "<cmd>cprev<cr>", { desc = "qf [p]rev" })
