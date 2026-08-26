local direnv = require("config.lib.direnv")
local icons = require("config.lib.icons")
local notify = require("config.lib.notify")
local path = require("config.lib.path")
local git = require("config.runtime.git")
local workspace = require("config.runtime.workspace")

local NOTIFY_TITLE = "Git worktree"
local notify_once = notify.with_title(NOTIFY_TITLE)

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

  local progress = notify.progress(NOTIFY_TITLE, "Running hook...")

  vim.system({ hook_script }, { cwd = worktree_path, text = true }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        progress.done()
      else
        progress.fail("Hook failed with code " .. result.code)
      end
    end)
  end)
end

local function switch_worktree()
  git.worktree_select({
    prompt = "Switch worktree",
    on_select = function(worktree)
      local progress = notify.progress(NOTIFY_TITLE, "Switching worktree...")

      local _, err = git.worktree_switch(worktree)

      if err then
        progress.fail(err)
        return
      end

      progress.done()
    end,
    on_empty = function()
      notify_once("No worktrees found")
    end,
  })
end

local function add_worktree()
  local worktrees = git.worktree_list()
  local bare_worktree = git.get_bare_worktree(worktrees)

  if not bare_worktree then
    notify_once("No bare worktree found")
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

    local progress = notify.progress(NOTIFY_TITLE, "Adding worktree...")

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
          progress.update("Adding worktree... cancelled")
          return
        end

        local worktree_path = branch:match("([^/]+)$")
        local created_worktree, created_err = git.worktree_add(bare_worktree.path, worktree_path, branch)

        if not created_worktree then
          progress.fail(created_err --[[@as string]])
          return
        end

        initialize_and_switch_to_worktree(created_worktree, bare_worktree.path)

        progress.done()
      end)

      return
    else
      local branch = choice.branch
      if not branch then
        progress.fail("Selected worktree has no branch")
        return
      end

      local worktree_path = branch:match("([^/]+)$")
      new_worktree, err = git.worktree_add(bare_worktree.path, worktree_path, branch)
    end

    if not new_worktree then
      progress.fail(err --[[@as string]])
      return
    end

    initialize_and_switch_to_worktree(new_worktree, bare_worktree.path)

    progress.done()
  end)
end

local function assign_branch()
  local worktree = git.get_active_worktree(git.worktree_list())

  if not worktree then
    notify_once("No active worktree found")
    return
  end

  vim.ui.input({
    prompt = "Assign branch: ",
  }, function(branch)
    if branch == nil or branch == "" then
      return
    end

    local progress = notify.progress(NOTIFY_TITLE, "Assigning branch...")

    local _, err = git.worktree_assign_branch(worktree.path, branch)

    if err then
      progress.fail(err)
      return
    end

    progress.done()
  end)
end

local function remove_worktree()
  git.worktree_select({
    prompt = "Remove worktree",
    on_select = function(worktree)
      local progress = notify.progress(NOTIFY_TITLE, "Removing worktree...")

      local _, err = git.worktree_remove(worktree)

      if err then
        progress.fail(err)
        return
      end

      progress.done()
    end,
    on_empty = function()
      notify_once("No worktrees found")
    end,
  })
end

vim.keymap.set("n", "<leader>gw", switch_worktree, { desc = "[g]it switch [w]orktree" })
vim.keymap.set("n", "<leader>ws", switch_worktree, { desc = "git [w]orktree [s]witch" })
vim.keymap.set("n", "<leader>wa", add_worktree, { desc = "git [w]orktree [a]dd" })
vim.keymap.set("n", "<leader>wb", assign_branch, { desc = "git [w]orktree assign [b]ranch" })
vim.keymap.set("n", "<leader>wr", remove_worktree, { desc = "git [w]orktree [r]emove" })
