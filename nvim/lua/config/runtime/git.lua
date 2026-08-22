local path = require("config.lib.path")
local Worktree = require("config.lib.worktree")
local workspace = require("config.runtime.workspace")

-- Git worktree/runtime orchestration and editor-facing flows.
local M = {}

---@return boolean
local function ensure_git()
  return vim.fn.executable("git") == 1
end

---@param cwd string
---@param worktree_path string
---@return string
local function resolve_worktree_path(cwd, worktree_path)
  if worktree_path:sub(1, 1) == "/" then
    return worktree_path
  end

  return vim.fs.joinpath(cwd, worktree_path)
end

local adjectives = {
  "amber",
  "brisk",
  "calm",
  "daring",
  "eager",
  "faint",
  "gentle",
  "hidden",
  "ivory",
  "jolly",
  "kind",
  "lively",
  "mellow",
  "nimble",
  "odd",
  "proud",
  "quiet",
  "rosy",
  "swift",
  "tidy",
  "vivid",
  "witty",
  "young",
  "zesty",
}

local nouns = {
  "anchor",
  "breeze",
  "canyon",
  "drift",
  "ember",
  "forest",
  "grove",
  "harbor",
  "island",
  "jewel",
  "meadow",
  "needle",
  "orbit",
  "pillar",
  "quartz",
  "river",
  "signal",
  "trail",
  "valley",
  "wave",
  "willow",
  "yonder",
  "zephyr",
  "harvest",
}

---@param cwd string
---@return string?
function M.get_default_branch(cwd)
  if not ensure_git() then
    return nil
  end

  local result = vim.system({ "git", "symbolic-ref", "refs/remotes/origin/HEAD" }, { cwd = cwd }):wait()

  if result.code == 0 and result.stdout then
    local branch = result.stdout:gsub("^refs/remotes/origin/", ""):gsub("%s+$", "")
    if branch ~= "" then
      return branch
    end
  end

  result = vim.system({ "git", "remote", "show", "origin" }, { cwd = cwd }):wait()

  if result.code == 0 and result.stdout then
    local branch = result.stdout:match("HEAD branch: ([^\n]+)")
    if branch then
      return branch
    end
  end

  return nil
end

---@param cwd string
---@param branch string
function M.remote_branch_exists(cwd, branch)
  if not ensure_git() then
    return false
  end

  local result = vim.system({ "git", "ls-remote", "--heads", "origin", branch }, { cwd = cwd }):wait()
  return result.code == 0 and result.stdout ~= nil and result.stdout ~= ""
end

---@param worktrees Worktree[]
---@return string[]
function M.local_branches(worktrees)
  if not ensure_git() then
    return {}
  end

  local checked_out = {}
  for _, worktree in ipairs(worktrees or {}) do
    if worktree.branch then
      checked_out[worktree.branch] = true
    end
  end

  local result = vim.system({ "git", "branch", "--format=%(refname:short)" }, { text = true }):wait()
  if result.code ~= 0 or not result.stdout then
    return {}
  end

  local branches = {}
  for branch in result.stdout:gmatch("([^\n]+)") do
    branch = branch:gsub("^%*%s+", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if branch ~= "" and not checked_out[branch] then
      table.insert(branches, branch)
    end
  end

  return branches
end

---@return string[]
function M.remote_only_branches()
  if not ensure_git() then
    return {}
  end

  local locals = {}
  for _, branch in ipairs(M.local_branches(M.worktree_list())) do
    locals[branch] = true
  end

  local result = vim.system({ "git", "branch", "-r" }, { text = true }):wait()
  if result.code ~= 0 or not result.stdout then
    return {}
  end

  local branches = {}
  for line in result.stdout:gmatch("([^\n]+)") do
    local branch = line:gsub("^%s+", ""):gsub("%s+$", "")
    branch = branch:gsub("^origin/HEAD%s+%-%>%s+", "")
    branch = branch:gsub("^origin/", "")
    if branch ~= "" and branch ~= "HEAD" and not line:find("%-%>") and not locals[branch] then
      table.insert(branches, branch)
    end
  end

  return branches
end

---@param bare_path string
---@return string
function M.random_worktree_name(bare_path)
  if not ensure_git() then
    return ""
  end

  math.randomseed(vim.uv.hrtime() % 2147483647)

  while true do
    local name = string.format("%s-%s", adjectives[math.random(#adjectives)], nouns[math.random(#nouns)])
    if not path.is_directory(vim.fs.joinpath(bare_path, name)) then
      return name
    end
  end
end

---@param cwd string
---@param worktree_path string
function M.worktree_add_detached(cwd, worktree_path)
  if not ensure_git() then
    return nil, "git not available"
  end

  local new_worktree = resolve_worktree_path(cwd, worktree_path)

  if path.is_directory(new_worktree) then
    return nil, "Worktree already exists"
  end

  local fetch_cmd = {
    "git",
    "fetch",
    "origin",
    "+refs/heads/*:refs/remotes/origin/*",
  }
  local result = vim.system(fetch_cmd, { cwd = cwd, text = true }):wait()
  if result.code ~= 0 then
    return nil, "git fetch failed: " .. vim.trim(result.stderr or "")
  end

  local default_branch = M.get_default_branch(cwd)
  local git_cmd = { "git", "worktree", "add", "--detach", worktree_path }
  if default_branch then
    table.insert(git_cmd, "origin/" .. default_branch)
  end

  result = vim.system(git_cmd, { cwd = cwd, text = true }):wait()

  vim.wait(3000, function()
    return path.is_directory(new_worktree)
  end)

  if not path.is_directory(new_worktree) then
    return nil, (result.stderr and result.stderr ~= "" and vim.trim(result.stderr)) or "Failed to add worktree"
  end

  return new_worktree, nil
end

---@param worktree_path string
---@param branch string
function M.worktree_assign_branch(worktree_path, branch)
  if not ensure_git() then
    return nil, "git not available"
  end

  local result = vim.system({ "git", "switch", "-c", branch }, { cwd = worktree_path, text = true }):wait()
  if result.code ~= 0 then
    result = vim.system({ "git", "checkout", "-b", branch }, { cwd = worktree_path, text = true }):wait()
  end

  if result.code ~= 0 then
    return nil, (result.stderr and result.stderr ~= "" and vim.trim(result.stderr)) or "Failed to assign branch"
  end

  return branch, nil
end

---@return Worktree[]
function M.worktree_list()
  if not ensure_git() then
    return {}
  end

  local result = vim.system({ "git", "worktree", "list", "--porcelain" }, { text = true }):wait()
  if result.code ~= 0 or not result.stdout then
    return {}
  end

  local output = result.stdout
  local entries = vim.split(output or "", "\n\n", { trimempty = true })
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
---@param worktree_path string
---@param branch string?
function M.worktree_add(cwd, worktree_path, branch)
  if not ensure_git() then
    return nil, "git not available"
  end

  local new_worktree = resolve_worktree_path(cwd, worktree_path)

  if path.is_directory(new_worktree) then
    return nil, "Worktree already exists"
  end

  local fetch_cmd = { "git", "fetch", "origin", "+refs/heads/*:refs/remotes/origin/*" }
  local result = vim.system(fetch_cmd, { cwd = cwd, text = true }):wait()

  if result.code ~= 0 then
    return nil, "git fetch failed: " .. vim.trim(result.stderr or "")
  end

  local new_branch = branch or worktree_path

  local base_branch
  if M.remote_branch_exists(cwd, new_branch) then
    base_branch = "origin/" .. new_branch
  else
    local default_branch = M.get_default_branch(cwd)
    if default_branch then
      base_branch = "origin/" .. default_branch
    end
  end

  local git_cmd = { "git", "worktree", "add", "-b", new_branch, worktree_path }

  if base_branch then
    table.insert(git_cmd, base_branch)
  end

  result = vim.system(git_cmd, { cwd = cwd, text = true }):wait()

  if result.code ~= 0 and result.stderr and result.stderr:find("already exists", 1, true) then
    local worktrees = M.worktree_list()
    for _, worktree in ipairs(worktrees) do
      if worktree.branch == new_branch then
        return nil, "Branch " .. new_branch .. " is already checked out in worktree at " .. worktree.path
      end
    end

    result = vim.system({ "git", "worktree", "add", worktree_path, new_branch }, { cwd = cwd, text = true }):wait()
  end

  vim.wait(3000, function()
    return path.is_directory(new_worktree)
  end)

  if not path.is_directory(new_worktree) then
    if vim.trim(result.stderr or "") ~= "" then
      return nil, vim.trim(result.stderr)
    end

    return nil, "Failed to add worktree"
  end

  return new_worktree, nil
end

---@param worktree Worktree
function M.worktree_switch(worktree)
  if worktree.prunable then
    return nil, "Can't switch to prunable worktree"
  end
  if not path.is_directory(worktree.path) then
    return nil, "Can't switch to worktree that does not exist"
  end
  if worktree:is_active() then
    return nil, "Can't switch to active worktree"
  end

  workspace.change_current_directory(worktree.path)

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
  if not ensure_git() then
    return nil, "git not available"
  end

  if not path.is_directory(worktree.path) then
    return nil, "Worktree does not exist"
  end
  if worktree.locked then
    return nil, "Can't remove locked worktree"
  end
  if worktree:is_active() then
    return nil, "Can't remove active worktree"
  end

  vim.system({ "git", "worktree", "remove", worktree.path }):wait()

  if path.is_directory(worktree.path) then
    local choice =
      vim.fn.confirm("Worktree contains modified or untracked files, use --force to delete it?", "&Yes\n&No", 2)
    if choice == 1 then
      vim.system({ "git", "worktree", "remove", "--force", worktree.path }):wait()
    end
  end

  if path.is_directory(worktree.path) then
    return nil, "Failed to remove worktree"
  end

  return worktree
end

function M.get_worktrees()
  local worktrees = M.worktree_list()

  table.remove(worktrees, 1)
  table.sort(worktrees, function(a, b)
    return a.name < b.name
  end)

  return worktrees
end

---@param worktrees Worktree[]
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
---@field on_empty? fun()

---@param args WorktreeSelectArgs
function M.worktree_select(args)
  local worktrees = M.get_worktrees()

  if #worktrees == 0 then
    if args.on_empty then
      args.on_empty()
    end
    return
  end

  vim.ui.select(
    worktrees,
    {
      prompt = args.prompt,
      ---@param worktree Worktree
      format_item = function(worktree)
        return worktree.display
      end,
    },
    ---@param worktree Worktree?
    function(worktree)
      if worktree then
        args.on_select(worktree)
      end
    end
  )
end

function M.is_inside_worktree()
  local result = vim.system({ "git", "rev-parse", "--is-inside-work-tree" }, { text = true }):wait()
  return result.code == 0 and result.stdout and result.stdout:match("true") ~= nil or false
end

return M
