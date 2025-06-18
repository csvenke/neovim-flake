local function dbui_tab()
  vim.cmd("tabnew")
  vim.cmd("DBUI")
end

local function execute_query()
  vim.cmd("vertical % DB")
  vim.cmd("wincmd =")
end

vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_win_position = "left"
vim.g.db_ui_show_database_icon = 1
vim.g.db_ui_use_nvim_notify = 1
vim.g.db_ui_show_help = 0
vim.g.db_ui_execute_on_save = 0

vim.keymap.set("n", "<leader>Dd", dbui_tab, { desc = "[D]BUI [t]oggle (shortcut)" })
vim.keymap.set("n", "<leader>DD", dbui_tab, { desc = "[D]BUI [t]oggle (shortcut)" })
vim.keymap.set("n", "<leader>Dt", dbui_tab, { desc = "[D]BUI [t]oggle" })
vim.keymap.set("n", "<leader>DT", dbui_tab, { desc = "[D]BUI [t]oggle" })
vim.keymap.set("n", "<leader>Da", "<cmd>DBUIAddConnection<cr>", { desc = "[D]BUI [a]dd connection" })

local group = vim.api.nvim_create_augroup("user-dadbod-hooks", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "dbui", "sql", "dbout" },
  group = group,
  callback = function(event)
    vim.keymap.set("n", "<C-q>", "<cmd>tabclose<cr>", { buffer = event.buf, desc = "[D]BUI close" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql" },
  group = group,
  callback = function(event)
    vim.keymap.set("n", "<F5>", execute_query, { buffer = event.buf, desc = "[D]BUI execute query" })
  end,
})
