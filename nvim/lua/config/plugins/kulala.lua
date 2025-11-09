local kulala = require("kulala")
local kulala_ui = require("kulala.ui")

kulala.setup({
  kulala_keymaps = false,
  global_keymaps = false,
  ui = {
    default_winbar_panes = { "body", "headers" },
    disable_news_popup = true,
    win_opts = {
      wo = {
        foldenable = false,
      },
    },
  },
})

local group = vim.api.nvim_create_augroup("user-kulala-hooks", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  group = group,
  callback = function(event)
    vim.keymap.set("n", "<F5>", kulala.run, { buffer = event.buf, desc = "Run request" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json.kulala_ui", "xml.kulala_ui" },
  group = group,
  callback = function(event)
    vim.keymap.set("n", "<tab>", kulala_ui.toggle_headers, { buffer = event.buf, desc = "Show next" })
  end,
})
