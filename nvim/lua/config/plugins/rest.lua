vim.g.loaded_rest_nvim = true

local group = vim.api.nvim_create_augroup("user-rest-hooks", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  group = group,
  callback = function(event)
    vim.keymap.set("n", "<F5>", "<cmd>Rest run<cr>", { buffer = event.buf, desc = "Run request" })
  end,
})
