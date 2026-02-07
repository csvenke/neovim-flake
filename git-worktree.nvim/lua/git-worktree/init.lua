--- Git Worktree Plugin for Neovim
--- Provides commands to manage git worktrees
---
---@class git-worktree.Config
---@field keymaps? {switch: string|nil|false, add: string|nil|false, remove: string|nil|false}
---@field hooks? {after_add: string|false}
---@field enable_direnv? boolean
---@field copy_shared? string|false
---@field notify? boolean
---@field icons? {worktree: string, branch: string, active: string}

local Git = require("git-worktree.git")
local Path = require("git-worktree.path")
local Direnv = require("git-worktree.direnv")

local M = {}

---@type git-worktree.Config
local config = {
  keymaps = {
    switch = nil,
    add = nil,
    remove = nil,
  },
  hooks = {
    after_add = ".hooks/after-worktree-add.sh",
  },
  enable_direnv = true,
  copy_shared = ".shared",
  notify = true,
  icons = {
    worktree = "",
    branch = "",
    active = "→",
  },
}

local NOTIFY_TITLE = "Git worktree"

---@param message string
---@param level number
---@param opts? table
local function notify(message, level, opts)
  if not config.notify then
    return
  end
  local options = vim.tbl_deep_extend("force", { title = NOTIFY_TITLE }, opts or {})
  vim.notify(message, level, options)
end

---@param worktree_path string
---@param bare_worktree_path string
local function run_post_add_hook(worktree_path, bare_worktree_path)
  if config.hooks.after_add == false then
    return
  end

  local hook_script = bare_worktree_path .. "/" .. config.hooks.after_add

  if vim.fn.filereadable(hook_script) ~= 1 then
    return
  end

  local notification = notify("Running hook...", vim.log.levels.INFO, {})
  local notify_opts = {
    replace = notification and notification.id,
  }

  vim.fn.jobstart(hook_script, {
    cwd = worktree_path,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        notify("Running hook... DONE", vim.log.levels.INFO, notify_opts)
      else
        notify("Hook failed with code " .. exit_code, vim.log.levels.ERROR, notify_opts)
      end
    end,
  })
end

function M.switch()
  Git.worktree_select({
    prompt = "Switch worktree",
    on_select = function(worktree)
      local notification = notify("Switching worktree...", vim.log.levels.INFO, {})
      local notify_opts = {
        replace = notification and notification.id,
      }

      local _, err = Git.worktree_switch(worktree)

      if err then
        notify(err, vim.log.levels.WARN, notify_opts)
        return
      end

      notify("Switching worktree... DONE", vim.log.levels.INFO, notify_opts)
    end,
    on_empty = function()
      notify("No worktrees found", vim.log.levels.INFO, {})
    end,
  })
end

function M.add()
  vim.ui.input({
    prompt = "Add worktree",
  }, function(choice)
    if choice == nil then
      return
    end

    local choices = vim.split(choice, "%s+", { plain = false })
    local path = choices[1]
    local branch = choices[2]

    local notification = notify("Adding worktree...", vim.log.levels.INFO, {})
    local notify_opts = {
      replace = notification and notification.id,
    }

    local worktrees = Git.worktree_list(config.icons)
    local bare_worktree = Git.get_bare_worktree(worktrees)

    if not bare_worktree then
      notify("No bare worktree found", vim.log.levels.WARN, notify_opts)
      return
    end

    local new_worktree, err = Git.worktree_add(bare_worktree.path, path, branch)

    if not new_worktree then
      notify(err --[[@as string]], vim.log.levels.ERROR, notify_opts)
      return
    end

    if config.copy_shared and config.copy_shared ~= false then
      Path.copy_directory(bare_worktree.path .. "/" .. config.copy_shared, new_worktree)
    end

    if config.enable_direnv then
      Direnv.allow_if_available(new_worktree)
    end

    Path.change_current_directory(new_worktree)
    run_post_add_hook(new_worktree, bare_worktree.path)

    notify("Adding worktree... DONE", vim.log.levels.INFO, notify_opts)
  end)
end

function M.remove()
  Git.worktree_select({
    prompt = "Remove worktree",
    on_select = function(worktree)
      local notification = notify("Removing worktree...", vim.log.levels.INFO, {})
      local notify_opts = {
        replace = notification and notification.id,
      }

      local _, err = Git.worktree_remove(worktree)

      if err then
        notify(err, vim.log.levels.WARN, notify_opts)
        return
      end

      notify("Removing worktree... DONE", vim.log.levels.INFO, notify_opts)
    end,
    on_empty = function()
      notify("No worktrees found", vim.log.levels.INFO, {})
    end,
  })
end

---@param user_config git-worktree.Config
function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})

  -- Set up keymaps if provided
  if config.keymaps.switch then
    vim.keymap.set("n", config.keymaps.switch, M.switch, { desc = "Git worktree: switch" })
  end
  if config.keymaps.add then
    vim.keymap.set("n", config.keymaps.add, M.add, { desc = "Git worktree: add" })
  end
  if config.keymaps.remove then
    vim.keymap.set("n", config.keymaps.remove, M.remove, { desc = "Git worktree: remove" })
  end
end

return M
