require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
    icons_enabled = true,
    always_show_tabline = false,
  },
  sections = {
    lualine_c = {},
    lualine_x = {
      function()
        return require("direnv").statusline()
      end,
      "encoding",
      "fileformat",
      "filetype",
    },
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
