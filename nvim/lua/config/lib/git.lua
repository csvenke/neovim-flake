local Path = require("config.lib.path")
local Text = require("config.lib.text")

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
--- @field to_display_string fun(self: Worktree, max_name_length: number, max_branch_length: number): string
--- @field is_active fun(self: Worktree): boolean

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
---@return string
function Worktree:to_display_string(max_name_length, max_branch_length)
  local items = {}

  if self.name then
    table.insert(items, "󰊢 ")
    table.insert(items, Text.pad_right(self.name, max_name_length))
    table.insert(items, "|")
  end

  if self.short_sha then
    table.insert(items, self.short_sha)
  end

  if self.detached then
    table.insert(items, Text.pad_right("(detached HEAD)", max_branch_length))
  elseif self.branch then
    table.insert(items, Text.pad_right(string.format("[%s]", self.branch), max_branch_length))
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

function M:worktree_list()
  local output = vim.fn.system("git worktree list --porcelain")
  local entries = vim.split(output, "\n\n", { trimempty = true })

  ---@type Worktree[]
  local worktrees = {}

  local max_name_length = 0
  local max_branch_length = 0
  local wrapper_length = 2

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
---@param on_success fun(path: string)
function M:worktree_add(cwd, path, on_success)
  local notification = vim.notify("Adding worktree...", vim.log.levels.INFO, {
    title = "Git",
  })

  local new_worktree = string.format("%s/%s", cwd, path)

  if Path:is_dir(new_worktree) then
    vim.notify("Worktree already exists", vim.log.levels.INFO, {
      title = "Git",
      replace = notification and notification.id,
    })
    return
  end

  vim.system({ "git", "worktree", "add", path }, { cwd = cwd }):wait()

  vim.wait(3000, function()
    return Path:is_dir(new_worktree)
  end)

  if not Path:is_dir(new_worktree) then
    vim.notify("Adding worktree... FAIL", vim.log.levels.INFO, {
      title = "Git",
      replace = notification and notification.id,
    })
    return
  end

  on_success(new_worktree)

  vim.notify("Adding worktree... DONE", vim.log.levels.INFO, {
    title = "Git",
    replace = notification and notification.id,
  })
end

---@param worktree Worktree
function M:worktree_switch(worktree)
  local notification = vim.notify("Switching worktree...", vim.log.levels.INFO, {
    title = "Git",
  })

  if worktree.prunable then
    vim.notify("Can't switch to prunable worktree", vim.log.levels.INFO, {
      title = "Git",
      replace = notification and notification.id,
    })
    return
  end

  if not Path:is_dir(worktree.path) then
    vim.notify("Can't switch to worktree that does not exist", vim.log.levels.INFO, {
      title = "Git",
      replace = notification and notification.id,
    })
    return
  end

  if worktree:is_active() then
    vim.notify("Can't switch to active worktree", vim.log.levels.INFO, {
      title = "Git",
      replace = notification and notification.id,
    })
    return
  end

  Path:change_current_directory(worktree.path)

  vim.wait(3000, function()
    return worktree:is_active()
  end)

  if worktree:is_active() then
    vim.notify("Switching worktree... DONE", vim.log.levels.INFO, {
      title = "Git",
      replace = notification and notification.id,
    })
  else
    vim.notify("Switching worktree... FAIL", vim.log.levels.INFO, {
      title = "Git",
      replace = notification and notification.id,
    })
  end
end

---@param worktree Worktree
function M:worktree_remove(worktree)
  local notification = vim.notify("Removing worktree...", vim.log.levels.INFO, {
    title = "Git",
  })

  if not Path:is_dir(worktree.path) then
    vim.notify("Worktree does not exist", vim.log.levels.INFO, {
      title = "Git",
      replace = notification and notification.id,
    })
    return
  end

  if worktree.locked then
    vim.notify("Can't remove locked worktree", vim.log.levels.INFO, {
      title = "Git",
      replace = notification and notification.id,
    })
    return
  end

  if worktree:is_active() then
    vim.notify("Can't remove active worktree", vim.log.levels.INFO, {
      title = "Git",
      replace = notification and notification.id,
    })
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
    vim.notify("Removing worktree... DONE", vim.log.levels.INFO, {
      title = "Git",
      replace = notification and notification.id,
    })
  else
    vim.notify("Removing worktree... FAIL", vim.log.levels.INFO, {
      title = "Git",
      replace = notification and notification.id,
    })
  end
end

---@return Worktree[]
function M:get_worktrees()
  local worktrees = self:worktree_list()
  table.remove(worktrees, 1)
  table.sort(worktrees, function(a, b)
    return a.name < b.name
  end)

  return worktrees
end

---@return Worktree|nil
function M:get_bare_worktree()
  local worktrees = self:worktree_list()

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

---@return Worktree|nil
function M:get_active_worktree()
  local worktrees = self:worktree_list()

  for _, worktree in ipairs(worktrees) do
    if worktree:is_active() then
      return worktree
    end
  end

  return nil
end

---@param prompt string
---@param on_select fun(worktree: Worktree)
function M:worktree_select(prompt, on_select)
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
    if worktree then
      on_select(worktree)
    end
  end)
end

---@return boolean
function M:is_inside_worktree()
  local git_check = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
  return vim.v.shell_error == 0 and git_check:match("true")
end

return M
