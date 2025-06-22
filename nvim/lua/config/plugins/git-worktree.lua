local Path = require("config.lib.path")
local Git = require("config.lib.git")
local Direnv = require("config.lib.direnv")

local function switch_worktree()
  Git:select_worktree("Switch worktree", function(worktree)
    if not worktree:is_active() then
      Path:cwd(worktree.path)
    end

    vim.notify("Switched to worktree " .. worktree.path)
  end)
end

local function add_worktree()
  vim.ui.input({
    prompt = "Add worktree",
  }, function(choice)
    if choice == nil then
      return
    end

    local root = Git:get_bare_worktree()

    Git:worktree_add(root.path, choice, function(new_worktree)
      Path:copy(root.path .. "/.shared", new_worktree)
      Direnv:allow(new_worktree)
      Path:cwd(new_worktree)

      vim.notify("Switched to worktree " .. new_worktree)
    end)
  end)
end

local function remove_worktree()
  Git:select_worktree("Remove worktree", function(worktree)
    Git:worktree_remove(worktree)
  end)
end

vim.keymap.set("n", "<leader>gw", switch_worktree, { desc = "[g]it switch [w]orktree" })
vim.keymap.set("n", "<leader>ws", switch_worktree, { desc = "git [w]orktree [s]witch" })
vim.keymap.set("n", "<leader>wa", add_worktree, { desc = "git [w]orktree [a]dd" })
vim.keymap.set("n", "<leader>wr", remove_worktree, { desc = "git [w]orktree [r]emove" })
