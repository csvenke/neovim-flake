require("nvim-tree").setup({
  ---@param buffer number
  on_attach = function(buffer)
    local api = require("nvim-tree.api")

    api.config.mappings.default_on_attach(buffer)

    vim.keymap.set("n", "l", api.node.open.edit, { desc = "open", buffer = buffer })
    vim.keymap.set("n", "h", api.node.navigate.parent_close, { desc = "close", buffer = buffer })
    vim.keymap.set("n", "s", api.node.open.horizontal, { desc = "open horizontal", buffer = buffer })
    vim.keymap.set("n", "v", api.node.open.vertical, { desc = "open vertical", buffer = buffer })
    vim.keymap.set("n", "y", api.fs.copy.node, { desc = "copy", buffer = buffer })
    vim.keymap.set("n", ".", api.tree.change_root_to_node, { desc = "change cwd", buffer = buffer })
  end,
  notify = {
    threshold = vim.log.levels.WARN,
  },
  filters = {
    dotfiles = false,
    git_ignored = false,
  },
  actions = {
    open_file = {
      window_picker = {
        enable = false,
      },
      resize_window = false,
    },
  },
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
  },
  view = {
    width = 40,
  },
  git = {
    show_on_dirs = true,
  },
  renderer = {
    highlight_git = "all",
    root_folder_label = false,
    icons = {
      git_placement = "right_align",
    },
  },
})

vim.keymap.set("n", "<leader>e", function()
  vim.cmd("NvimTreeToggle")
  vim.api.nvim_exec_autocmds("VimResized", {})
end, { desc = "file [e]xplorer" })
