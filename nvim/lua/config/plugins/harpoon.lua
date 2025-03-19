local harpoon = require("harpoon")

harpoon.setup({
  global_settings = {
    -- Use the git worktree root directory as part of the filename for mark storage
    mark_file = function()
      local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
      local worktree_name = git_root:match("[^/]+$") or ""
      return vim.fn.stdpath("data") .. "/harpoon-" .. worktree_name .. ".json"
    end,
  },
})

vim.keymap.set("n", "<M-a>", function()
  harpoon:list():add()
  vim.notify("File added")
end, { desc = "harpoon file" })

vim.keymap.set("n", "<M-e>", function()
  local toggle_opts = {
    border = "rounded",
    title_pos = "center",
    ui_width_ratio = 0.40,
  }

  harpoon.ui:toggle_quick_menu(harpoon:list(), toggle_opts)
end, { desc = "open harpoon window" })

vim.keymap.set("n", "<M-1>", function()
  harpoon:list():select(1)
end, { desc = "goto [1]" })

vim.keymap.set("n", "<M-2>", function()
  harpoon:list():select(2)
end, { desc = "goto [2]" })

vim.keymap.set("n", "<M-3>", function()
  harpoon:list():select(3)
end, { desc = "goto [3]" })

vim.keymap.set("n", "<M-4>", function()
  harpoon:list():select(4)
end, { desc = "goto [4]" })
