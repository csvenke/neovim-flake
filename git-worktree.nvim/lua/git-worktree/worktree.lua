local utils = require("git-worktree.utils")

---@class WorktreeArgs
---@field name? string
---@field path? string
---@field sha? string
---@field short_sha? string
---@field branch? string|nil
---@field bare? boolean
---@field detached? boolean
---@field locked? boolean
---@field prunable? boolean

---@class Worktree
---@field name string
---@field path string
---@field sha string
---@field short_sha string
---@field branch string|nil
---@field bare boolean
---@field detached boolean
---@field locked boolean
---@field prunable boolean
---@field display string
---@field to_display_string fun(self: Worktree, max_name_length: number, max_branch_length: number, icons?: {worktree: string, branch: string, active: string}): string
---@field is_active fun(self: Worktree): boolean

local Worktree = {}
Worktree.__index = Worktree

---@param args WorktreeArgs
---@return Worktree
function Worktree.new(args)
  local self = setmetatable({
    name = args.name or "",
    path = args.path or "",
    sha = args.sha or "0000000000000000000000000000000000000000",
    short_sha = args.short_sha or "0000000",
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
function Worktree.from_entry(entry)
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
    name = name,
    path = path,
    sha = sha,
    short_sha = short_sha,
    branch = branch,
    bare = hasFlag("bare"),
    detached = hasFlag("detached"),
    locked = hasFlag("locked"),
    prunable = hasFlag("prunable"),
  })
end

---@param max_name_length number
---@param max_branch_length number
---@param icons? {worktree: string, branch: string, active: string}
---@return string
function Worktree:to_display_string(max_name_length, max_branch_length, icons)
  local items = {}
  local icon_config = icons or {}

  if self.name then
    table.insert(items, (icon_config.worktree or utils.icons.git) .. " ")
    table.insert(items, utils.pad_right(self.name, max_name_length))
    table.insert(items, "|")
  end

  if self.short_sha then
    table.insert(items, self.short_sha)
  end

  if self.detached then
    table.insert(items, utils.pad_right("(detached HEAD)", max_branch_length))
  elseif self.branch then
    table.insert(items, utils.pad_right(string.format("[%s]", self.branch), max_branch_length))
  end

  if self.locked then
    table.insert(items, "locked")
  end

  if self.prunable then
    table.insert(items, "prunable")
  end

  return table.concat(items, " ")
end

function Worktree:is_active()
  return vim.fn.getcwd() == self.path
end

return Worktree
