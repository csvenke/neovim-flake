require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
    icons_enabled = true,
  },
  tabline = {
    lualine_z = {
      { "tabs", show_modified_status = false },
    },
  },
})
