vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("user-vim-enter-telescope", { clear = true }),
  callback = function()
    require("telescope").setup({
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
      },
    })
    require("telescope").load_extension("fzf")
    require("telescope").load_extension("notify")
    require("telescope").load_extension("noice")
    require("telescope").load_extension("ui-select")

    local builtin = require("telescope.builtin")

    -- Builtin
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
    vim.keymap.set("n", "<leader>/", builtin.live_grep, { desc = "Find in files (Grep)" })
    vim.keymap.set("n", "<leader>?", builtin.live_grep, { desc = "Find in files (Grep)" })
    vim.keymap.set("n", "<leader>:", builtin.command_history, { desc = "Command history" })
    vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[s]earch recent files" })
    vim.keymap.set("n", "<leader><leader>", builtin.find_files, { desc = "[s]earch [f]iles" })

    -- noice
    vim.keymap.set("n", "<leader>sn", "<cmd>Telescope notify<cr>", { desc = "[s]earch [n]otify" })
    vim.keymap.set("n", "<leader>sN", "<cmd>Telescope noice<cr>", { desc = "[s]earch [N]oice" })
  end,
})
