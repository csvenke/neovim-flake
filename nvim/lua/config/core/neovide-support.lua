if vim.g.neovide then
  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end

  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_position_animation_length = 0
  vim.g.neovide_cursor_animation_length = 0.00
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_animate_in_insert_mode = false
  vim.g.neovide_cursor_animate_command_line = false
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.g.neovide_scroll_animation_length = 0.00

  vim.keymap.set({ "n", "v" }, "<C-c>", '"+y', { desc = "copy to clipboard" })
  vim.keymap.set({ "n", "v" }, "<C-v>", '"+P', { desc = "paste from clipboard" })
  vim.keymap.set("i", "<C-v>", '<ESC>l"+Pli', { desc = "paste in insert mode" })
  vim.keymap.set("c", "<C-v>", "<C-R>+", { desc = "paste in command mode" })

  vim.keymap.set("n", "<C-=>", function()
    change_scale_factor(1.25)
  end)

  vim.keymap.set("n", "<C-->", function()
    change_scale_factor(1 / 1.25)
  end)

  vim.keymap.set("n", "<C-+>", function()
    change_scale_factor(1 * 1.25)
  end)
end
