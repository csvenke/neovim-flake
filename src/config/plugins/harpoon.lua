local harpoon = require("harpoon")

harpoon.setup()

vim.keymap.set("n", "<C-a>", function()
  harpoon:list():add()
  vim.notify("File added")
end, { desc = "harpoon file" })

vim.keymap.set("n", "<C-e>", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "open harpoon window" })

vim.keymap.set("n", "<C-p>", function()
  harpoon:list():prev()
end, { desc = "goto [p]revious" })

vim.keymap.set("n", "<C-n>", function()
  harpoon:list():next()
end, { desc = "goto [n]ext" })

vim.keymap.set("n", "<leader>1", function()
  harpoon:list():select(1)
end, { desc = "goto [1]" })

vim.keymap.set("n", "<leader>2", function()
  harpoon:list():select(2)
end, { desc = "goto [2]" })

vim.keymap.set("n", "<leader>3", function()
  harpoon:list():select(3)
end, { desc = "goto [3]" })

vim.keymap.set("n", "<leader>4", function()
  harpoon:list():select(4)
end, { desc = "goto [4]" })
