local kulala = require("kulala")

kulala.setup({
  kulala_keymaps = false,
  global_keymaps = false,
  ui = {
    default_winbar_panes = { "body", "headers" },
    disable_news_popup = true,
    max_response_size = 5242880, -- 5 MB
    win_opts = {
      wo = {
        foldenable = false,
      },
    },
  },
  lsp = {
    filetypes = { "http", "rest" },
  },
})

local group = vim.api.nvim_create_augroup("user-kulala-hooks", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "http", "rest" },
  group = group,
  callback = function(event)
    vim.keymap.set("n", "<F5>", kulala.run, { buffer = event.buf, desc = "Run request" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json.kulala_ui", "text.kulala_ui", "xml.kulala_ui" },
  group = group,
  callback = function(event)
    vim.keymap.set("n", "<tab>", function()
      require("kulala.ui").toggle_headers()
    end, { buffer = event.buf, desc = "Toggle headers" })
  end,
})
