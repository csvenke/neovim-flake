require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
    icons_enabled = true,
    always_show_tabline = false,
  },
  tabline = {
    lualine_z = {
      {
        "tabs",
        show_modified_status = false,
      },
    },
  },
})
