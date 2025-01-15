require("snacks").setup({
  bigfile = {
    enabled = true,
  },
})

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
