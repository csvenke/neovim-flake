require("snacks").setup({
  bigfile = {},
  notifier = {},
  quickfile = {},
  input = {
    win = {
      relative = "cursor",
    },
  },
})

local zen = require("snacks.zen")

vim.keymap.set("n", "<leader>z", function()
  zen.zen({
    toggles = {
      dim = false,
    },
    win = {
      width = 180,
    },
  })
end, { desc = "[z]en mode" })

local bufdelete = require("snacks.bufdelete")

vim.keymap.set("n", "<leader>bd", function()
  bufdelete.delete()
end, { desc = "[b]uffer [d]elete" })

vim.keymap.set("n", "<leader>bD", function()
  bufdelete.delete({ force = true })
end, { desc = "[b]uffer [D]elete (force)" })

vim.keymap.set("n", "<leader>bo", function()
  bufdelete.other()
end, { desc = "[b]uffer delete [o]thers" })

vim.keymap.set("n", "<leader>bO", function()
  bufdelete.other({ force = true })
end, { desc = "[b]uffer delete [O]thers" })
