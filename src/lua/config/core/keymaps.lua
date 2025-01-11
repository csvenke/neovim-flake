vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- disable macros
vim.keymap.set("n", "q", "<Nop>")
vim.keymap.set("n", "Q", "<Nop>")

-- quitting
vim.keymap.set("n", "<leader>qq", "<cmd>wqa<cr>", { desc = "[q]uit" })
vim.keymap.set("n", "<leader>qQ", "<cmd>qa<cr>", { desc = "[q]uit (without saving)" })
vim.keymap.set("n", "<C-q>", "<cmd>q<cr>", { desc = "[q]uit" })

-- saving
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { desc = "[s]ave" })
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Wa", "wa", {})
vim.api.nvim_create_user_command("WA", "wa", {})

-- navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move left" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move right" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move down" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move up" })

-- shifting
vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Shift up" })
vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Shift down" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Shift right" })
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Shift left" })

-- programmer shortcuts
vim.keymap.set("i", "<C-i>", "{}<Left>", { desc = "{" })
vim.keymap.set("i", "<C-o>", "[]<Left>", { desc = "[" })

-- quickfix list
vim.keymap.set("n", "<C-n>", "<cmd>cnext<cr>", { desc = "qf [n]ext" })
vim.keymap.set("n", "<C-p>", "<cmd>cprev<cr>", { desc = "qf [p]rev" })