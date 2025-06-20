local git = require("config.lib.git")
local path = require("config.lib.path")
local direnv = require("config.lib.direnv")

local function switch_worktree()
  git.select_worktree("Switch worktree", function(worktree)
    if vim.fn.getcwd() == worktree then
      return
    end

    path.cwd(worktree)

    vim.notify("Switched to worktree " .. worktree)
  end)
end

local function add_worktree()
  vim.ui.input({
    prompt = "Add worktree",
  }, function(choice)
    if choice == nil then
      return
    end

    local root = git.get_bare_worktree()

    git.worktree_add(root.path, choice, function(new_worktree)
      path.copy(root .. "/.shared", new_worktree)
      direnv.allow(new_worktree)
      path.cwd(new_worktree)

      vim.notify("Switched to worktree " .. new_worktree)
    end)
  end)
end

local function remove_worktree()
  git.select_worktree("Remove worktree", function(worktree)
    git.worktree_remove(worktree)
  end)
end

vim.keymap.set("n", "<leader>gw", switch_worktree, { desc = "[g]it switch [w]orktree" })
vim.keymap.set("n", "<leader>ws", switch_worktree, { desc = "git [w]orktree [s]witch" })
vim.keymap.set("n", "<leader>wa", add_worktree, { desc = "git [w]orktree [a]dd" })
vim.keymap.set("n", "<leader>wr", remove_worktree, { desc = "git [w]orktree [r]emove" })
