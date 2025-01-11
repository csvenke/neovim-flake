require("telescope").setup({
  defaults = {
    layout_strategy = "flex",
    layout_config = {
      horizontal = {
        preview_width = 0.5,
      },
    },
  },
  pickers = {
    find_files = {
      find_command = { "rg", "--files", "--sortr=modified" },
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

vim.lsp.handlers["textDocument/definition"] = builtin.lsp_definitions
vim.lsp.handlers["textDocument/references"] = builtin.lsp_references
vim.lsp.handlers["textDocument/implementation"] = builtin.lsp_implementations
vim.lsp.handlers["textDocument/typeDefinition"] = builtin.lsp_type_definitions

vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[s]earch [h]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[s]earch [k]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[s]earch [f]iles" })
vim.keymap.set("n", "<leader>sg", builtin.git_files, { desc = "[s]earch [g]it files" })
vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, { desc = "[s]earch [s]ymbols" })
vim.keymap.set("n", "<leader>sS", builtin.lsp_workspace_symbols, { desc = "[s]earch [S]ymbols (workspace)" })
vim.keymap.set("n", "<leader>st", builtin.tagstack, { desc = "[s]earch [t]agstack" })
vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[s]earch [b]uffers" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[s]earch [w]ord" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[s]earch [d]iagnostics" })
vim.keymap.set("n", "<leader>so", builtin.vim_options, { desc = "[s]earch vim [o]ptions" })
vim.keymap.set("n", "<leader>sc", builtin.quickfix, { desc = "[s]earch qui[c]kfix" })
vim.keymap.set("n", "<leader>/", builtin.live_grep, { desc = "Find in files (Grep)" })
vim.keymap.set("n", "<leader>?", builtin.live_grep, { desc = "Find in files (Grep)" })
vim.keymap.set("n", "<leader>:", builtin.command_history, { desc = "Command history" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[s]earch recent files" })
vim.keymap.set("n", "<leader><leader>", builtin.find_files, { desc = "[s]earch [f]iles" })

require("modules.telescope.multigrep").setup()
