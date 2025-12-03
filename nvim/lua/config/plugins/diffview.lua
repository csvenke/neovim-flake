local actions = require("diffview.actions")

local default_keymaps = {
  { "n", "<leader>gd", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
  { "n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
  { "n", "<C-q>", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
  { "n", "<tab>", actions.select_next_entry, { desc = "Select next entry" } },
  { "n", "<s-tab>", actions.select_prev_entry, { desc = "Select previous entry" } },
}

local file_panel = {
  { "n", "<leader>gd", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
  { "n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
  { "n", "<C-q>", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
  { "n", "<tab>", actions.select_next_entry, { desc = "Select next entry" } },
  { "n", "<s-tab>", actions.select_prev_entry, { desc = "Select previous entry" } },
  { "n", "j", actions.next_entry, { desc = "Next" } },
  { "n", "k", actions.prev_entry, { desc = "Previous" } },
  { "n", "<cr>", actions.select_entry, { desc = "Select entry" } },
}

require("diffview").setup({
  default_args = {
    DiffviewOpen = { "--imply-local" },
  },
  enhanced_diff_hl = true,
  keymaps = {
    disable_defaults = true,
    view = default_keymaps,
    diff1 = default_keymaps,
    diff2 = default_keymaps,
    diff3 = default_keymaps,
    diff4 = default_keymaps,
    file_panel = file_panel,
    file_history_panel = default_keymaps,
    option_panel = default_keymaps,
    help_panel = default_keymaps,
  },
  view = {
    merge_tool = {
      layout = "diff3_mixed",
      disable_diagnostics = true,
    },
  },
  hooks = {
    diff_buf_read = function()
      vim.opt_local.foldenable = false
      vim.opt_local.culopt = "number"
      vim.opt_local.fillchars:append({ diff = " " })
      vim.opt_local.diffopt:append("context:999")
    end,
  },
})

vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen HEAD --selected-file<cr>", { desc = "[g]it [d]iff view" })
vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewOpen HEAD<cr>", { desc = "[g]it [d]iff view" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "[g]it diff [h]istory (current file)" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "[g]it diff [H]istory" })
vim.keymap.set("n", "<leader>gr", "<cmd>DiffviewOpen origin/HEAD...HEAD<cr>", { desc = "[g]it code [r]eview" })
