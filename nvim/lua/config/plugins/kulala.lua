local kulala = require("kulala")

kulala.setup({})

local group = vim.api.nvim_create_augroup("user-http-hooks", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  group = group,
  callback = function(event)
    vim.keymap.set("n", "<F5>", kulala.run, { buffer = event.buf, desc = "Run request" })
  end,
})
