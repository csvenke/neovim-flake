local utils = require("config.utils")

---@param worktree_line string
---@return string name
---@return string extra
local function parse_worktree_line(worktree_line)
  local path, extra = worktree_line:match("^(%S+)%s*(.*)")
  local name = path:match("([^/]+)$")
  return name, extra
end

---@param prompt string
---@param on_select fun(path: string)
local function select_worktree(prompt, on_select)
  local worktrees = utils.get_worktrees()

  if #worktrees == 0 then
    vim.notify("No worktrees found")
    return
  end

  -- calculate max worktree name length
  local max_name_length = 0
  for _, worktree in ipairs(worktrees) do
    local name = parse_worktree_line(worktree)
    max_name_length = math.max(max_name_length, #name)
  end

  vim.ui.select(worktrees, {
    prompt = prompt,
    format_item = function(worktree)
      local name, extra = parse_worktree_line(worktree)
      return string.format("%-" .. max_name_length .. "s | %s", name, extra)
    end,
  }, function(choice)
    if choice == nil then
      return
    end

    local path = choice:match("^%S+")
    on_select(path)
  end)
end

local function switch_worktree()
  select_worktree("Switch worktree", function(worktree)
    if vim.fn.getcwd() == worktree then
      return
    end

    utils.change_working_directory(worktree)
    vim.notify("Switched to worktree " .. worktree)
  end)
end

local function remove_worktree()
  select_worktree("Remove worktree", function(worktree)
    if vim.fn.getcwd() == worktree then
      vim.notify("Can't remove active worktree")
      return
    end

    vim.system({ "git", "worktree", "remove", worktree }):wait()

    if vim.fn.isdirectory(worktree) == 1 then
      local choice =
        vim.fn.confirm("Worktree contains modified or untracked files, use --force to delete it?", "&Yes\n&No", 2)
      if choice == 1 then
        vim.system({ "git", "worktree", "remove", "--force", worktree }):wait()
      end
    end

    if vim.fn.isdirectory(worktree) == 0 then
      vim.notify("Removed worktree " .. worktree)
    end
  end)
end

---@param root string
---@param worktree string
local function copy_shared(root, worktree)
  local shared_dir = root .. "/.shared"

  if vim.fn.isdirectory(shared_dir) == 1 then
    vim.system({ "cp", "-r", shared_dir .. "/.", worktree }):wait()
  end
end

---@param worktree string
local function direnv_setup(worktree)
  local has_direnv = vim.fn.executable("direnv") == 1
  local has_envrc = vim.fn.filereadable(worktree .. "/.envrc") == 1

  if has_direnv and has_envrc then
    vim.system({ "direnv", "allow", worktree }):wait()
  end
end

local function add_worktree()
  vim.ui.input({
    prompt = "Add worktree",
  }, function(input)
    if input == nil then
      return
    end

    local root_worktree = utils.get_root_worktree()
    local new_worktree = string.format("%s/%s", root_worktree, input)

    if vim.fn.isdirectory(new_worktree) == 1 then
      vim.notify("Worktree already exists")
      return
    end

    vim.system({ "git", "worktree", "add", input }, { cwd = root_worktree }):wait()

    copy_shared(root_worktree, new_worktree)
    direnv_setup(new_worktree)
    utils.change_working_directory(new_worktree)

    vim.notify("Switched to worktree " .. new_worktree)
  end)
end

vim.keymap.set("n", "<leader>gw", switch_worktree, { desc = "[g]it switch [w]orktree" })
vim.keymap.set("n", "<leader>wa", add_worktree, { desc = "git [w]orktree [a]dd" })
vim.keymap.set("n", "<leader>wr", remove_worktree, { desc = "git [w]orktree [r]emove" })
