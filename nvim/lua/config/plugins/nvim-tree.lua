require("nvim-tree").setup({
  ---@param buffer number
  on_attach = function(buffer)
    local api = require("nvim-tree.api")

    ---@param desc string
    local function opts(desc)
      return { desc = desc, buffer = buffer, noremap = true, silent = true, nowait = true }
    end

    api.config.mappings.default_on_attach(buffer)

    vim.keymap.set("n", "l", api.node.open.edit, opts("open"))
    vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("close"))
    vim.keymap.set("n", "s", api.node.open.horizontal, opts("open horizontal"))
    vim.keymap.set("n", "v", api.node.open.vertical, opts("open vertical"))
    vim.keymap.set("n", "y", api.fs.copy.node, opts("copy"))
    vim.keymap.set("n", ".", api.tree.change_root_to_node, opts("change cwd"))
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
    icons = {
      git_placement = "right_align",
    },
  },
})

vim.keymap.set("n", "<leader>e", function()
  vim.cmd("NvimTreeToggle")
  vim.api.nvim_exec_autocmds("VimResized", {})
end, { desc = "file [e]xplorer" })
