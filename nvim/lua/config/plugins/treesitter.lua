require("nvim-ts-autotag").setup({})

require("nvim-treesitter").setup({
  ensure_installed = {},
  auto_install = false,
  highlight = { enable = true },
  indent = { enable = true },
})
