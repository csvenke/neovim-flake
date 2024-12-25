local harpoon = require("harpoon")

harpoon.setup({})

vim.keymap.set("n", "<A-a>", function()
  harpoon:list():add()
  vim.notify("File added")
end, { desc = "harpoon file" })

vim.keymap.set("n", "<A-e>", function()
  local toggle_opts = {
    border = "rounded",
    title_pos = "center",
    ui_width_ratio = 0.40,
  }

  harpoon.ui:toggle_quick_menu(harpoon:list(), toggle_opts)
end, { desc = "open harpoon window" })

vim.keymap.set("n", "<A-1>", function()
  harpoon:list():select(1)
end, { desc = "goto [1]" })

vim.keymap.set("n", "<A-2>", function()
  harpoon:list():select(2)
end, { desc = "goto [2]" })

vim.keymap.set("n", "<A-3>", function()
  harpoon:list():select(3)
end, { desc = "goto [3]" })

vim.keymap.set("n", "<A-4>", function()
  harpoon:list():select(4)
end, { desc = "goto [4]" })
