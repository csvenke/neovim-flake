local Git = require("config.lib.git")

require("telescope").setup({
  defaults = {
    layout_strategy = "flex",
    layout_config = {
      horizontal = {
        preview_width = 0.5,
      },
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({}),
    },
  },
})
require("telescope").load_extension("fzf")
require("telescope").load_extension("ui-select")

local builtin = require("telescope.builtin")

local function find_files_smart()
  if Git:is_inside_worktree() then
    builtin.git_files({ show_untracked = true })
  else
    builtin.find_files()
  end
end

vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[s]earch [h]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[s]earch [k]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[s]earch [f]iles" })
vim.keymap.set("n", "<leader>sj", builtin.jumplist, { desc = "[s]earch [j]umplist" })
vim.keymap.set("n", "<leader>sg", builtin.git_files, { desc = "[s]earch [g]it files" })
vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "[g]it [s]tatus" })
vim.keymap.set("n", "<leader>st", builtin.tagstack, { desc = "[s]earch [t]agstack" })
vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[s]earch [b]uffers" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[s]earch [w]ord" })
vim.keymap.set("n", "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "[s]earch [d]iagnostics" })
vim.keymap.set("n", "<leader>sD", "<cmd>Telescope diagnostics<cr>", { desc = "[s]earch [D]iagnostics (workspace)" })
vim.keymap.set("n", "<leader>so", builtin.vim_options, { desc = "[s]earch vim [o]ptions" })
vim.keymap.set("n", "<leader>sc", builtin.quickfix, { desc = "[s]earch qui[c]kfix" })
vim.keymap.set("n", "<leader>/", builtin.live_grep, { desc = "Find in files (Grep)" })
vim.keymap.set("n", "<leader>?", builtin.live_grep, { desc = "Find in files (Grep)" })
vim.keymap.set("n", "<leader>:", builtin.command_history, { desc = "Command history" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[s]earch recent files" })
vim.keymap.set("n", "<leader><leader>", find_files_smart, { desc = "[s]earch [f]iles" })

require("config.plugins.telescope.multigrep").setup()
