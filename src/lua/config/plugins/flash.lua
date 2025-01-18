require("flash").setup({
  modes = {
    char = {
      enabled = false,
    },
  },
})

vim.keymap.set("n", "s", function()
  require("flash").jump()
end, { desc = "flash" })

vim.keymap.set("n", "S", function()
  require("flash").treesitter()
end, { desc = "flash" })
