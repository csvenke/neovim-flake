require("neo-tree").setup({
  source_selector = {
    winbar = true,
    statusLine = true,
  },
  sources = {
    "filesystem",
    "git_status",
  },
  filesystem = {
    hijack_netrw_behavior = "disabled",
    use_libuv_file_watcher = true,
    follow_current_file = { enabled = true },
    filtered_items = {
      visible = true,
      show_hidden_count = true,
      hide_dotfiles = false,
      hide_gitignored = true,
      never_show = {
        ".git",
      },
    },
  },
  window = {
    mappings = {
      ["<space>"] = "none",
      ["?"] = "none",
      ["/"] = "none",
      ["l"] = "open",
      ["h"] = "close_node",
      ["L"] = "next_source",
      ["H"] = "prev_source",
      ["s"] = "open_split",
      ["v"] = "open_vsplit",
    },
  },
})

vim.keymap.set("n", "<leader>e", function()
  require("neo-tree.command").execute({ source = "filesystem", toggle = true })
  vim.api.nvim_exec_autocmds("VimResized", {})
end, { desc = "file [e]xplorer" })
