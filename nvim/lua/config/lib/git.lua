local Path = require("config.lib.path")

local M = {}

--- @class WorktreeArgs
--- @field name? string
--- @field path? string
--- @field sha? string
--- @field short_sha? string
--- @field branch? string|nil
--- @field bare? boolean
--- @field detached? boolean
--- @field locked? boolean
--- @field prunable? boolean

--- @class Worktree
--- @field name string
--- @field path string
--- @field sha string
--- @field short_sha string
--- @field branch string|nil
--- @field bare boolean
--- @field detached boolean
--- @field locked boolean
--- @field prunable boolean
--- @field display string
--- @field to_display_string fun(self: Worktree, max_name_length: number): string
--- @field is_active fun(self: Worktree): boolean

local Worktree = {}
Worktree.__index = Worktree

---@param args WorktreeArgs
---@return Worktree
function Worktree.new(args)
  local self = setmetatable({
    name = args.name or "",
    path = args.path or "",
    sha = args.sha or "",
    short_sha = args.short_sha or "",
    branch = args.branch,
    bare = args.bare or false,
    detached = args.detached or false,
    locked = args.locked or false,
    prunable = args.prunable or false,
    display = "",
  }, Worktree)

  return self
end

---@param entry string
---@return Worktree
function Worktree.fromEntry(entry)
  local path = entry:match("worktree ([^\n]+)")
  local name = nil
  if path then
    path = path
    name = path:match("([^/]+)$")
  end

  local head = entry:match("HEAD ([^\n]+)")
  local sha = nil
  local short_sha = nil
  if head then
    sha = head
    short_sha = head:sub(1, 7)
  end

  local branch = entry:match("branch ([^\n]+)")
  if branch then
    branch = branch:match("refs/heads/(.+)") or branch
  end

  local function hasFlag(flag)
    return entry:find(flag) ~= nil
  end

  return Worktree.new({
    name = name or "",
    path = path,
    sha = sha,
    short_sha = short_sha or "",
    branch = branch,
    bare = hasFlag("bare"),
    detached = hasFlag("detached"),
    locked = hasFlag("locked"),
    prunable = hasFlag("prunable"),
  })
end

---@param max_name_length number
---@return string
function Worktree:to_display_string(max_name_length)
  local detached_label = "(detached HEAD)"
  local max_name_or_detached_length = math.max(max_name_length, #detached_label)

  ---@param s string
  local function pad(s)
    return string.format("%-" .. max_name_or_detached_length .. "s", s)
  end

  local extra = {}

  if self.short_sha ~= "" then
    table.insert(extra, self.short_sha)
  end

  if self.detached then
    table.insert(extra, pad(detached_label))
  elseif self.branch then
    table.insert(extra, pad(string.format("[%s]", self.branch)))
  end

  if self.locked then
    table.insert(extra, "🔒")
  end

  if self.prunable then
    table.insert(extra, "🗑️")
  end

  return string.format("%s | %s", pad(self.name), table.concat(extra, " "))
end

function Worktree:is_active()
  return vim.fn.getcwd() == self.path
end

function M:worktree_list()
  local output = vim.fn.system("git worktree list --porcelain")
  local entries = vim.split(output, "\n\n", { trimempty = true })

  ---@type Worktree[]
  local worktrees = {}
  local max_name_length = 0

  for _, entry in ipairs(entries) do
    local worktree = Worktree.fromEntry(entry)

    if not worktree.bare then
      max_name_length = math.max(max_name_length, #worktree.name)
    end

    table.insert(worktrees, worktree)
  end

  for _, worktree in ipairs(worktrees) do
    worktree.display = worktree:to_display_string(max_name_length + 2)
  end

  return worktrees
end

---@param cwd string
---@param path string
---@param callback fun(path: string)
function M:worktree_add(cwd, path, callback)
  local new_worktree = string.format("%s/%s", cwd, path)

  if Path:is_dir(new_worktree) then
    vim.notify("Worktree already exists")
    return
  end

  vim.system({ "git", "worktree", "add", path }, { cwd = cwd }):wait()

  if Path:is_dir(new_worktree) then
    callback(new_worktree)
  end
end

---
---@param worktree Worktree
function M:worktree_remove(worktree)
  if not Path:is_dir(worktree.path) then
    vim.notify("Worktree does not exist")
    return
  end

  if worktree:is_active() then
    vim.notify("Can't remove active worktree")
    return
  end

  vim.system({ "git", "worktree", "remove", worktree.path }):wait()

  if Path:is_dir(worktree.path) then
    local choice =
        vim.fn.confirm("Worktree contains modified or untracked files, use --force to delete it?", "&Yes\n&No", 2)
    if choice == 1 then
      vim.system({ "git", "worktree", "remove", "--force", worktree.path }):wait()
    end
  end

  if not Path:is_dir(worktree.path) then
    vim.notify("Removed worktree " .. worktree.path)
  else
    vim.notify("Failed to remove worktree " .. worktree.path)
  end
end

---@return Worktree[]
function M:get_worktrees()
  local worktrees = self:worktree_list()
  table.remove(worktrees, 1)
  return worktrees
end

---@return Worktree
function M:get_bare_worktree()
  local worktrees = self:worktree_list()
  local first = table.remove(worktrees, 1)
  return first
end

---@param prompt string
---@param on_select fun(worktree: Worktree)
function M:select_worktree(prompt, on_select)
  local worktrees = self:get_worktrees()

  if #worktrees == 0 then
    vim.notify("No worktrees found")
    return
  end

  vim.ui.select(worktrees, {
    prompt = prompt,
    ---@param worktree Worktree
    format_item = function(worktree)
      return worktree.display
    end,
  }, function(worktree)
    if worktree ~= nil then
      on_select(worktree)
    end
  end)
end

return M
