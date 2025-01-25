vim.keymap.set("n", "<leader>x", ":.lua<CR>", { desc = "e[x]ecute line" })
vim.keymap.set("n", "<leader>X", "<cmd>source %<CR>", { desc = "e[x]ecute buffer" })
vim.keymap.set("v", "<leader>x", ":lua<CR>", { desc = "e[x]ecute selection" })
