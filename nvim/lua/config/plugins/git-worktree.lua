local direnv = require("config.lib.direnv")
local icons = require("config.lib.icons")
local path = require("config.lib.path")
local git = require("config.runtime.git")
local workspace = require("config.runtime.workspace")

local NOTIFY_TITLE = "Git worktree"

--- @param worktree_path string
--- @param bare_worktree_path string
local function initialize_and_switch_to_worktree(worktree_path, bare_worktree_path)
  path.copy_directory(bare_worktree_path .. "/.shared", worktree_path)
  direnv.allow_if_available(worktree_path)
  workspace.change_current_directory(worktree_path)

  local hook_script = vim.fs.joinpath(bare_worktree_path, ".hooks", "after-worktree-add.sh")

  if not path.is_file(hook_script) then
    return
  end

  local notification = vim.notify("Running hook...", vim.log.levels.INFO, {
    title = NOTIFY_TITLE,
    timeout = false,
  })
  local notify_opts = {
    title = NOTIFY_TITLE,
    replace = notification and notification.id,
    timeout = 5000,
  }

  vim.system({ hook_script }, { cwd = worktree_path, text = true }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify("Running hook... DONE", vim.log.levels.INFO, notify_opts)
      else
        vim.notify("Hook failed with code " .. result.code, vim.log.levels.ERROR, notify_opts)
      end
    end)
  end)
end

local function switch_worktree()
  git.worktree_select({
    prompt = "Switch worktree",
    on_select = function(worktree)
      local notification = vim.notify("Switching worktree...", vim.log.levels.INFO, {
        title = NOTIFY_TITLE,
      })
      local notify_opts = {
        title = NOTIFY_TITLE,
        replace = notification and notification.id,
      }

      local _, err = git.worktree_switch(worktree)

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
  local worktrees = git.worktree_list()
  local bare_worktree = git.get_bare_worktree(worktrees)

  if not bare_worktree then
    vim.notify("No bare worktree found", vim.log.levels.INFO, {
      title = NOTIFY_TITLE,
    })
    return
  end

  --- @class WorktreeItem
  --- @field kind string
  --- @field label string
  --- @field branch? string

  --- @type WorktreeItem[]
  local items = {
    { kind = "detached", label = "Detached" },
    { kind = "new", label = "New branch..." },
  }

  for _, branch in ipairs(git.remote_only_branches()) do
    table.insert(items, { kind = "remote", branch = branch, label = branch .. " (remote)" })
  end

  for _, branch in ipairs(git.local_branches(worktrees)) do
    table.insert(items, { kind = "local", branch = branch, label = branch })
  end

  --- @param item WorktreeItem
  local function format_item(item)
    if item.kind == "detached" then
      return icons.branch_new .. "  " .. item.label
    end
    if item.kind == "new" then
      return icons.branch_new .. "  " .. item.label
    end

    return icons.branch .. "  " .. item.label
  end

  vim.ui.select(items, {
    prompt = "Add worktree",
    format_item = format_item,
  }, function(choice)
    if not choice then
      return
    end

    local notification = vim.notify("Adding worktree...", vim.log.levels.INFO, {
      title = NOTIFY_TITLE,
      timeout = false,
    })
    local notify_opts = {
      title = NOTIFY_TITLE,
      replace = notification and notification.id,
      timeout = 5000,
    }

    local new_worktree
    local err

    if choice.kind == "detached" then
      local worktree_path = git.random_worktree_name(bare_worktree.path)
      new_worktree, err = git.worktree_add_detached(bare_worktree.path, worktree_path)
    elseif choice.kind == "new" then
      vim.ui.input({
        prompt = "New branch: ",
      }, function(branch)
        if branch == nil or branch == "" then
          vim.notify("Adding worktree... cancelled", vim.log.levels.INFO, notify_opts)
          return
        end

        local worktree_path = branch:match("([^/]+)$")
        local created_worktree, created_err = git.worktree_add(bare_worktree.path, worktree_path, branch)

        if not created_worktree then
          vim.notify(created_err --[[@as string]], vim.log.levels.INFO, notify_opts)
          return
        end

        initialize_and_switch_to_worktree(created_worktree, bare_worktree.path)

        vim.notify("Adding worktree... DONE", vim.log.levels.INFO, notify_opts)
      end)

      return
    else
      local branch = choice.branch
      if not branch then
        vim.notify("Selected worktree has no branch", vim.log.levels.ERROR, notify_opts)
        return
      end

      local worktree_path = branch:match("([^/]+)$")
      new_worktree, err = git.worktree_add(bare_worktree.path, worktree_path, branch)
    end

    if not new_worktree then
      vim.notify(err --[[@as string]], vim.log.levels.INFO, notify_opts)
      return
    end

    initialize_and_switch_to_worktree(new_worktree, bare_worktree.path)

    vim.notify("Adding worktree... DONE", vim.log.levels.INFO, notify_opts)
  end)
end

local function assign_branch()
  local worktree = git.get_active_worktree(git.worktree_list())

  if not worktree then
    vim.notify("No active worktree found", vim.log.levels.INFO, {
      title = NOTIFY_TITLE,
    })
    return
  end

  vim.ui.input({
    prompt = "Assign branch: ",
  }, function(branch)
    if branch == nil or branch == "" then
      return
    end

    local notification = vim.notify("Assigning branch...", vim.log.levels.INFO, {
      title = NOTIFY_TITLE,
    })
    local notify_opts = {
      title = NOTIFY_TITLE,
      replace = notification and notification.id,
    }

    local _, err = git.worktree_assign_branch(worktree.path, branch)

    if err then
      vim.notify(err, vim.log.levels.INFO, notify_opts)
      return
    end

    vim.notify("Assigning branch... DONE", vim.log.levels.INFO, notify_opts)
  end)
end

local function remove_worktree()
  git.worktree_select({
    prompt = "Remove worktree",
    on_select = function(worktree)
      local notification = vim.notify("Removing worktree...", vim.log.levels.INFO, {
        title = NOTIFY_TITLE,
      })
      local notify_opts = {
        title = NOTIFY_TITLE,
        replace = notification and notification.id,
      }

      local _, err = git.worktree_remove(worktree)

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
vim.keymap.set("n", "<leader>wb", assign_branch, { desc = "git [w]orktree assign [b]ranch" })
vim.keymap.set("n", "<leader>wr", remove_worktree, { desc = "git [w]orktree [r]emove" })
