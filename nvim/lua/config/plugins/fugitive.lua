vim.keymap.set("n", "<leader>gs", "<cmd>rightbelow Git<cr>", { desc = "[g]it [s]tatus" })
vim.keymap.set("n", "<leader>gl", "<cmd>rightbelow Git log<cr>", { desc = "[g]it [l]og" })
vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit! HEAD:%<cr>", { desc = "[g]it [d]iff view (current file)" })
vim.keymap.set("n", "<leader>gh", "<cmd>rightbelow Gclog %<cr>", { desc = "[g]it diff [h]istory (current file)" })
vim.keymap.set("n", "<leader>gH", "<cmd>rightbelow Gclog<cr>", { desc = "[g]it diff [H]istory" })

require("codediff").setup()
