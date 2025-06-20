local M = {}

--- @class Worktree
--- @field name string
--- @field path string
--- @field head string
--- @field branch string|nil
--- @field bare boolean
--- @field detached boolean
--- @field locked boolean
--- @field prunable boolean
--- @field pretty string

function M.worktree_list()
  local output = vim.fn.system("git worktree list --porcelain")
  local worktrees = {}
  local max_name_length = 0
  local entries = vim.split(output, "\n\n", { trimempty = true })

  for _, entry in ipairs(entries) do
    local lines = vim.split(entry, "\n", { trimempty = true })

    ---@type Worktree
    local worktree = {
      name = "",
      path = "",
      head = "",
      branch = nil,
      bare = false,
      detached = false,
      locked = false,
      prunable = false,
      pretty = "",
    }

    for _, line in ipairs(lines) do
      if line:match("^worktree ") then
        worktree.path = line:sub(10)
        worktree.name = worktree.path:match("([^/]+)$")
      elseif line:match("^HEAD ") then
        worktree.head = line:sub(6)
      elseif line:match("^branch ") then
        worktree.branch = line:sub(8)
      elseif line == "bare" then
        worktree.bare = true
      elseif line == "detached" then
        worktree.detached = true
      elseif line == "locked" then
        worktree.locked = true
      elseif line == "prunable" then
        worktree.prunable = true
      end
    end

    if not worktree.bare then
      max_name_length = math.max(max_name_length, #worktree.name)
    end

    table.insert(worktrees, worktree)
  end

  for _, worktree in ipairs(worktrees) do
    local extra = {}

    -- Add branch or head information
    if worktree.detached then
      table.insert(extra, string.format("[%s]", worktree.head:sub(1, 7)))
    elseif worktree.branch then
      table.insert(extra, string.format("(%s)", worktree.branch))
    else
      table.insert(extra, string.format("[%s]", worktree.head:sub(1, 7)))
    end

    -- Add status indicators
    local status = {}
    if worktree.bare then
      table.insert(status, "bare")
    end
    if worktree.detached then
      table.insert(status, "detached")
    end
    if worktree.locked then
      table.insert(status, "locked")
    end
    if worktree.prunable then
      table.insert(status, "prunable")
    end

    if #status > 0 then
      table.insert(extra, string.format("{%s}", table.concat(status, ", ")))
    end

    local pretty = string.format("%-" .. max_name_length .. "s | %s", worktree.name, table.concat(extra, " "))

    worktree.pretty = pretty

    table.insert(worktree, worktree)
  end

  return worktrees
end

---@param cwd string
---@param path string
---@param callback fun(path: string)
function M.worktree_add(cwd, path, callback)
  local new_worktree = string.format("%s/%s", cwd, path)

  if vim.fn.isdirectory(new_worktree) == 1 then
    vim.notify("Worktree already exists", vim.log.levels.WARN)
    return
  end

  vim.system({ "git", "worktree", "add", path }, { cwd = cwd }):wait()

  if vim.fn.isdirectory(new_worktree) == 1 then
    callback(new_worktree)
  end
end
---
---@param path string
function M.worktree_remove(path)
  if vim.fn.getcwd() == path then
    vim.notify("Can't remove active worktree")
    return nil
  end

  vim.system({ "git", "worktree", "remove", path }):wait()

  if vim.fn.isdirectory(path) == 1 then
    local choice =
      vim.fn.confirm("Worktree contains modified or untracked files, use --force to delete it?", "&Yes\n&No", 2)
    if choice == 1 then
      vim.system({ "git", "worktree", "remove", "--force", path }):wait()
    end
  end

  if vim.fn.isdirectory(path) == 0 then
    vim.notify("Removed worktree " .. path, vim.log.levels.INFO)
  else
    vim.notify("Failed to remove worktree " .. path, vim.log.levels.ERROR)
  end

  return path
end

---@return Worktree[]
function M.get_worktrees()
  local worktrees = M.worktree_list()
  table.remove(worktrees, 1)
  return worktrees
end

---@return Worktree
function M.get_bare_worktree()
  local worktrees = M.worktree_list()
  local first = table.remove(worktrees, 1)
  return first
end

---@param prompt string
---@param on_select fun(path: string)
function M.select_worktree(prompt, on_select)
  local worktrees = M.get_worktrees()

  if #worktrees == 0 then
    vim.notify("No worktrees found")
    return
  end

  vim.ui.select(worktrees, {
    prompt = prompt,
    ---@param worktree Worktree
    format_item = function(worktree)
      return worktree.pretty
    end,
  }, function(worktree)
    if worktree == nil then
      return
    end

    on_select(worktree.path)
  end)
end

return M
