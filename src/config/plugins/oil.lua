require("oil").setup({
  default_file_explorer = true,
  use_default_keymaps = false,
  skip_confirm_for_simple_edits = true,
  watch_for_changes = true,
  keymaps = {
    ["_"] = "actions.open_cwd",
    ["-"] = "actions.parent",
    ["<CR>"] = "actions.select",
    ["g."] = "actions.cd",
    ["gx"] = "actions.open_external",
    ["ff"] = {
      function()
        require("telescope.builtin").find_files({
          cwd = require("oil").get_current_dir(),
        })
      end,
      mode = "n",
      nowait = true,
      desc = "Find files in current directory",
    },
  },
  view_options = {
    show_hidden = true,
    is_always_hidden = function(name)
      local hidden_names = { "..", ".git" }
      return vim.tbl_contains(hidden_names, name)
    end,
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
