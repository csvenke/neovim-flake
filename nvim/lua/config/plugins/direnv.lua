require("direnv").setup({
  autoload_direnv = true,
  statusline = {
    enabled = true,
  },
  keybindings = {
    allow = "<Nop>",
    deny = "<Nop>",
    reload = "<Nop>",
    edit = "<Nop>",
  },
})
