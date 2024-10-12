require("oil").setup({
  default_file_explorer = true,
  use_default_keymaps = false,
  keymaps = {
    ["_"] = "actions.open_cwd",
    ["-"] = "actions.parent",
    ["."] = "actions.cd",
    ["<CR>"] = "actions.select",
    ["g."] = "actions.toggle_hidden",
    ["gx"] = "actions.open_external",
  },
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
