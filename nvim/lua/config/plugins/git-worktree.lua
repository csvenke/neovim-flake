local Direnv = require("config.lib.direnv")
local Path = require("config.lib.path")
local Git = require("config.lib.git")

local NOTIFY_TITLE = "Git worktree"

local function switch_worktree()
  Git.worktree_select({
    prompt = "Switch worktree",
    on_select = function(worktree)
      local notification = vim.notify("Switching worktree...", vim.log.levels.INFO, {
        title = NOTIFY_TITLE,
      })
      local notify_opts = {
        title = NOTIFY_TITLE,
        replace = notification and notification.id,
      }

      local _, err = Git.worktree_switch(worktree)

      if err then
        vim.notify(err, vim.log.levels.INFO, notify_opts)
        return
      end

      vim.notify("Switching worktree... DONE", vim.log.levels.INFO, notify_opts)
    end,
    on_empty = function()
      vim.notify("No worktrees found", vim.log.levels.INFO, {
        title = NOTIFY_TITLE,
      })
    end,
  })
end

local function add_worktree()
  vim.ui.input({
    prompt = "Add worktree",
  }, function(choice)
    if choice == nil then
      return
    end
    local notification = vim.notify("Adding worktree...", vim.log.levels.INFO, {
      title = NOTIFY_TITLE,
    })
    local notify_opts = {
      title = NOTIFY_TITLE,
      replace = notification and notification.id,
    }

    local worktrees = Git.worktree_list()
    local bare_worktree = Git.get_bare_worktree(worktrees)

    if not bare_worktree then
      vim.notify("No bare worktree found", vim.log.levels.INFO, notify_opts)
      return
    end

    local new_worktree, err = Git.worktree_add(bare_worktree.path, choice)

    if not new_worktree then
      vim.notify(err --[[@as string]], vim.log.levels.INFO, notify_opts)
      return
    end

    Path.copy_directory(bare_worktree.path .. "/.shared", new_worktree)
    Direnv.allow_if_available(new_worktree)

    vim.notify("Adding worktree... DONE", vim.log.levels.INFO, notify_opts)
  end)
end

local function remove_worktree()
  Git.worktree_select({
    prompt = "Remove worktree",
    on_select = function(worktree)
      local notification = vim.notify("Removing worktree...", vim.log.levels.INFO, {
        title = NOTIFY_TITLE,
      })
      local notify_opts = {
        title = NOTIFY_TITLE,
        replace = notification and notification.id,
      }

      local _, err = Git.worktree_remove(worktree)

      if err then
        vim.notify(err, vim.log.levels.INFO, notify_opts)
        return
      end

      vim.notify("Removing worktree... DONE", vim.log.levels.INFO, notify_opts)
    end,
    on_empty = function()
      vim.notify("No worktrees found", vim.log.levels.INFO, {
        title = NOTIFY_TITLE,
      })
    end,
  })
end

vim.keymap.set("n", "<leader>gw", switch_worktree, { desc = "[g]it switch [w]orktree" })
vim.keymap.set("n", "<leader>ws", switch_worktree, { desc = "git [w]orktree [s]witch" })
vim.keymap.set("n", "<leader>wa", add_worktree, { desc = "git [w]orktree [a]dd" })
vim.keymap.set("n", "<leader>wr", remove_worktree, { desc = "git [w]orktree [r]emove" })
