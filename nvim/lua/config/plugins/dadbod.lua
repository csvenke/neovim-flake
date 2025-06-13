vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_win_position = "right"
vim.g.db_ui_show_database_icon = 1
vim.g.db_ui_use_nvim_notify = 1
vim.g.db_ui_show_help = 0
vim.g.db_ui_execute_on_save = 0

vim.keymap.set("n", "<leader>DD", "<cmd>DBUIToggle<cr>", { desc = "[D]BUI [t]oggle" })
vim.keymap.set("n", "<leader>Dt", "<cmd>DBUIToggle<cr>", { desc = "[D]BUI [t]oggle" })
vim.keymap.set("n", "<leader>Da", "<cmd>DBUIAddConnection<cr>", { desc = "[D]BUI [a]dd connection" })
