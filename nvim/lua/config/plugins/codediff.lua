require("codediff").setup({
  highlights = {
    line_insert = "DiffAdd",
    line_delete = "DiffDelete",
    char_insert = "DiffAdd",
    char_delete = "DiffDelete",
  },
  explorer = {
    initial_focus = "modified",
  },
  keymaps = {
    view = {
      quit = "<C-q>",
      toggle_explorer = "<Nop>",
      next_hunk = "<Nop>",
      prev_hunk = "<Nop>",
      next_file = "<Tab>",
      prev_file = "<S-Tab>",
      diff_get = "<Nop>",
      diff_put = "<Nop>",
    },
    explorer = {
      select = "l",
      hover = "K",
    },
    conflict = {
      accept_incoming = "<Nop>",
      accept_current = "<Nop>",
      accept_both = "<Nop>",
      discard = "<Nop>",
      next_conflict = "<Nop>",
      prev_conflict = "<Nop>",
      diffget_incoming = "<Nop>",
      diffget_current = "<Nop>",
    },
  },
})

vim.keymap.set("n", "<leader>gd", "<cmd>CodeDiff<cr>", { desc = "[g]it [d]iff view" })
vim.keymap.set("n", "<leader>gh", "<cmd>CodeDiff history %<cr>", { desc = "[g]it [h]istory" })
vim.keymap.set("n", "<leader>gH", "<cmd>CodeDiff history<cr>", { desc = "[g]it [H]istory" })
vim.keymap.set("n", "<leader>gr", "<cmd>CodeDiff origin/HEAD<cr>", { desc = "[g]it code [r]eview" })
