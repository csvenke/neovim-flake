vim.g.loaded_rest_nvim = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  callback = function(event)
    vim.keymap.set("n", "<F5>", "<cmd>Rest run<cr>", { buffer = event.buf, desc = "Run request" })
  end,
})
