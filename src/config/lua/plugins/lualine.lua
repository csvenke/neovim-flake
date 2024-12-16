require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
    icons_enabled = vim.g.have_nerd_font,
  },
  extensions = { "neo-tree", "trouble" },
})
