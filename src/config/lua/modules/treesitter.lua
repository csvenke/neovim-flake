require("nvim-ts-autotag").setup({})

require("nvim-treesitter.configs").setup({
  ensure_installed = {},
  auto_install = false,
  highlight = { enable = true },
  indent = { enable = true },
})
