vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("user-vim-enter-which-key", { clear = true }),
  callback = function()
    local wk = require("which-key")
    wk.setup({})
    wk.add({
      { "<leader>a", group = "[a]i" },
      { "<leader>b", group = "[b]uffer" },
      { "<leader>c", group = "[c]ode" },
      { "<leader>d", group = "[d]iagnostics" },
      { "<leader>g", group = "[g]it" },
      { "<leader>q", group = "[q]uit" },
      { "<leader>s", group = "[s]earch" },
      { "<leader>t", group = "[t]est" },
    })
  end,
})
