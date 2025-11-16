local has_direnv, direnv = pcall(require, "direnv")
local has_grapple, grapple = pcall(require, "grapple")

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
      {
        function()
          return grapple.statusline()
        end,
        cond = function()
          return has_grapple
        end,
      },
      {
        function()
          return direnv.statusline()
        end,
        cond = function()
          return has_direnv
        end,
      },
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
