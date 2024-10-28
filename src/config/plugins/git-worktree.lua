local function git_switch_worktree()
  local data = vim.system({ "git", "worktree", "list" }, { text = true }):wait()
  local results = vim.split(data.stdout or "", "\n", { trimempty = true })
  table.remove(results, 1)

  if #results == 0 then
    vim.notify("No worktrees found", vim.log.levels.INFO)
    return
  end

  vim.ui.select(results, { prompt = "Switch worktree" }, function(choice)
    if choice == nil then
      return
    end

    local path = choice:match("^%S+")
    require("git-worktree").switch_worktree(path)
  end)
end

local hooks = require("git-worktree.hooks")
hooks.register(hooks.type.SWITCH, hooks.builtins.update_current_buffer_on_switch)

vim.keymap.set("n", "<leader>gw", git_switch_worktree, { desc = "[g]it switch [w]orktree" })
