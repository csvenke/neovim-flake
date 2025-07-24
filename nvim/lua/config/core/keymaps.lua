-- clear search highlighting
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- preserve clipboard when pasting
vim.keymap.set("x", "p", '"_dP')

-- disable macros
vim.keymap.set("n", "q", "<Nop>")
vim.keymap.set("n", "Q", "<Nop>")

-- quitting
vim.keymap.set("n", "<leader>qq", "<cmd>wa | qa<cr>", { desc = "[q]uit" })
vim.keymap.set("n", "<leader>qQ", "<cmd>qa<cr>", { desc = "[q]uit (without saving)" })
vim.keymap.set("n", "<C-q>", "<cmd>q<cr>", { desc = "[q]uit" })

-- saving
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>wa<cr>", { desc = "[s]ave" })
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Wa", "wa", {})
vim.api.nvim_create_user_command("WA", "wa", {})

-- tab management
vim.keymap.set("n", "<S-l>", "<cmd>tabnext<cr>", { desc = "next tab" })
vim.keymap.set("n", "<S-h>", "<cmd>tabprevious<cr>", { desc = "previous tab" })
vim.keymap.set("n", "<C-w>t", "<cmd>tabnew<cr>", { desc = "New tab" })

-- split navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move left" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move right" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move down" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move up" })

-- programming shortcuts
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Shift right" })
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Shift left" })
vim.keymap.set("i", "<C-j>", "{}<Left>", { desc = "{" })
vim.keymap.set("i", "<C-k>", "[]<Left>", { desc = "[" })
vim.keymap.set("i", "<C-o>", "()<Left>", { desc = "(" })

-- move selected lines
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selected down", silent = true })
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selected up", silent = true })
vim.keymap.set("v", "<C-h>", "<gv", { desc = "Move selected left", silent = true })
vim.keymap.set("v", "<C-l>", ">gv", { desc = "Move selected right", silent = true })
