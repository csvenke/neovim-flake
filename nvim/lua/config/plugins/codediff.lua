require("codediff").setup({
  highlights = {
    line_insert = "DiffAdd",
    line_delete = "DiffDelete",
    char_insert = "DiffAdd",
    char_delete = "DiffDelete",
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
      refresh = "R",
      toggle_view_mode = "i",
      toggle_stage = "<Space>", -- Stage/unstage selected file
      stage_all = "a", -- Stage all files
      unstage_all = "U", -- Unstage all files
      restore = "d", -- Discard changes (restore file)
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
vim.keymap.set("n", "<leader>gD", "<cmd>CodeDiff<cr>", { desc = "[g]it [D]iff explorer" })
vim.keymap.set("n", "<leader>gh", "<cmd>Git log -p %<cr>", { desc = "[g]it diff [h]istory (current file)" })
vim.keymap.set("n", "<leader>gr", "<cmd>CodeDiff FETCH_HEAD HEAD<cr>", { desc = "[g]it code [r]eview" })
