require("oil").setup({
  default_file_explorer = true,
  use_default_keymaps = false,
  keymaps = {
    ["_"] = "actions.open_cwd",
    ["-"] = "actions.parent",
    ["<CR>"] = "actions.select",
    ["gx"] = "actions.open_external",
    ["g."] = "actions.toggle_hidden",
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
