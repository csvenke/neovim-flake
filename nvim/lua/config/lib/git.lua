local Path = require("config.lib.path")
local Worktree = require("config.lib.worktree")

local M = {}

function M.worktree_list()
  local output = vim.fn.system("git worktree list --porcelain")
  local entries = vim.split(output, "\n\n", { trimempty = true })
  local max_name_length = 0
  local max_branch_length = 0
  local wrapper_length = 2

  ---@type Worktree[]
  local worktrees = {}

  for _, entry in ipairs(entries) do
    local worktree = Worktree.from_entry(entry)

    if not worktree.bare then
      max_name_length = math.max(max_name_length, #worktree.name)
      if worktree.detached then
        max_branch_length = math.max(max_branch_length, #"detached HEAD")
      end
      if worktree.branch then
        max_branch_length = math.max(max_branch_length, #worktree.branch)
      end
    end

    table.insert(worktrees, worktree)
  end

  for _, worktree in ipairs(worktrees) do
    worktree.display = worktree:to_display_string(max_name_length, max_branch_length + wrapper_length)
  end

  return worktrees
end

---@param cwd string
---@param path string
---@param branch string?
---@return string?
---@return string?
function M.worktree_add(cwd, path, branch)
  local new_worktree = string.format("%s/%s", cwd, path)

  if Path.is_directory(new_worktree) then
    return nil, "Worktree already exists"
  end

  local git_cmd = { "git", "worktree", "add" }

  if branch then
    table.insert(git_cmd, "-b")
    table.insert(git_cmd, branch)
  end

  table.insert(git_cmd, path)

  vim.system(git_cmd, { cwd = cwd }):wait()

  vim.wait(3000, function()
    return Path.is_directory(new_worktree)
  end)

  if not Path.is_directory(new_worktree) then
    return nil, "Failed to add worktree"
  end

  return new_worktree, nil
end

---@param worktree Worktree
---@return Worktree?
---@return string?
function M.worktree_switch(worktree)
  if worktree.prunable then
    return nil, "Can't switch to prunable worktree"
  end
  if not Path.is_directory(worktree.path) then
    return nil, "Can't switch to worktree that does not exist"
  end
  if worktree:is_active() then
    return nil, "Can't switch to active worktree"
  end

  Path.change_current_directory(worktree.path)

  vim.wait(3000, function()
    return worktree:is_active()
  end)

  if not worktree:is_active() then
    return nil, "Failed to switch to worktree"
  end

  return worktree
end

---@param worktree Worktree
---@return Worktree?
---@return string?
function M.worktree_remove(worktree)
  if not Path.is_directory(worktree.path) then
    return nil, "Worktree does not exist"
  end
  if worktree.locked then
    return nil, "Can't remove locked worktree"
  end
  if worktree:is_active() then
    return nil, "Can't remove active worktree"
  end

  vim.system({ "git", "worktree", "remove", worktree.path }):wait()

  if Path.is_directory(worktree.path) then
    local choice =
      vim.fn.confirm("Worktree contains modified or untracked files, use --force to delete it?", "&Yes\n&No", 2)
    if choice == 1 then
      vim.system({ "git", "worktree", "remove", "--force", worktree.path }):wait()
    end
  end

  if Path.is_directory(worktree.path) then
    return nil, "Failed to remove worktree"
  end

  return worktree
end

---@return Worktree[]
function M.get_worktrees()
  local worktrees = M.worktree_list()

  table.remove(worktrees, 1)
  table.sort(worktrees, function(a, b)
    return a.name < b.name
  end)

  return worktrees
end

---@param worktrees Worktree[]
---@return Worktree?
function M.get_bare_worktree(worktrees)
  if #worktrees == 1 then
    return table.remove(worktrees, 1)
  end

  for _, worktree in ipairs(worktrees) do
    if worktree.bare then
      return worktree
    end
  end

  return nil
end

---@param worktrees Worktree[]
---@return Worktree?
function M.get_active_worktree(worktrees)
  for _, worktree in ipairs(worktrees) do
    if worktree:is_active() then
      return worktree
    end
  end

  return nil
end

---@class WorktreeSelectArgs
---@field prompt string
---@field on_select fun(worktree: Worktree)
---@field on_empty fun()

---@param args WorktreeSelectArgs
function M.worktree_select(args)
  local worktrees = M.get_worktrees()

  if #worktrees == 0 then
    if args.on_empty then
      args.on_empty()
    end
    return
  end

  vim.ui.select(worktrees, {
    prompt = args.prompt,
    ---@param worktree Worktree
    format_item = function(worktree)
      return worktree.display
    end,
  }, function(worktree)
    if worktree then
      args.on_select(worktree)
    end
  end)
end

---@return boolean
function M.is_inside_worktree()
  local git_check = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
  return vim.v.shell_error == 0 and git_check:match("true")
end

---@class RunAfterWorktreeAddHookArgs
---@field bare_worktree_path string
---@field new_worktree_path string
---@field on_complete fun(success: boolean)?

---@param args RunAfterWorktreeAddHookArgs
function M.run_after_worktree_add_hook(args)
  local hook_script = args.bare_worktree_path .. "/.hooks/after-worktree-add.sh"

  if vim.fn.executable(hook_script) ~= 1 then
    return
  end

  local title = "Git worktree hook"
  local hook_notification = vim.notify("Running hook...", vim.log.levels.INFO, {
    title = title,
  })

  vim.system({ hook_script }, { cwd = args.new_worktree_path }, function(result)
    vim.schedule(function()
      local hook_notify_opts = {
        title = title,
        replace = hook_notification and hook_notification.id,
      }
      local success = result.code == 0
      if success then
        vim.notify("Running hook... DONE", vim.log.levels.INFO, hook_notify_opts)
      else
        vim.notify("Running hook... FAILED", vim.log.levels.WARN, hook_notify_opts)
      end
      if args.on_complete then
        args.on_complete(success)
      end
    end)
  end)
end

return M
