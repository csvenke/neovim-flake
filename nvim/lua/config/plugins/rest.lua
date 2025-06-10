vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  callback = function()
    local buffer = vim.api.nvim_get_current_buf()

    vim.keymap.set("n", "<F5>", "<cmd>Rest run<cr>", { buffer = buffer, desc = "Run request" })
  end,
})
