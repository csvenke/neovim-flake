---@return string[]
local function git_worktree_list()
  local output = vim.fn.system("git worktree list")
  local worktrees = vim.split(output, "\n", { trimempty = true })
  return worktrees
end

---@return string[]
local function get_worktrees()
  local worktrees = git_worktree_list()
  table.remove(worktrees, 1)
  return worktrees
end

---@return string
local function get_root_worktree()
  local worktrees = git_worktree_list()
  local first = table.remove(worktrees, 1)
  return first:match("^%S+")
end

---@param prompt string
---@param on_select fun(path: string)
local function select_worktree(prompt, on_select)
  local worktrees = get_worktrees()

  if #worktrees == 0 then
    vim.notify("No worktrees found")
    return
  end

  vim.ui.select(worktrees, {
    prompt = prompt,
  }, function(choice)
    if choice == nil then
      return
    end

    local path = choice:match("^%S+")
    on_select(path)
  end)
end

---@param working_directory string
local function change_working_directory(working_directory)
  local current_path = vim.fn.expand("%:.")
  local editable_file = vim.fn.filereadable(current_path) == 1 and current_path or "."
  vim.cmd("cd " .. working_directory)
  vim.cmd("clearjumps")
  vim.cmd("edit " .. editable_file)
end

local function switch_worktree()
  select_worktree("Change worktree", change_working_directory)
end

local function remove_worktree()
  select_worktree("Remove worktree", function(worktree_path)
    vim.system({ "git", "worktree", "remove", worktree_path }):wait()
    vim.notify("Removed worktree " .. worktree_path)
  end)
end

local function add_worktree()
  vim.ui.input({
    prompt = "Create worktree",
  }, function(input)
    if input == nil then
      return
    end

    local root = get_root_worktree()
    local new_worktree = root .. "/" .. input

    if vim.fn.isdirectory(new_worktree) == 1 then
      vim.notify("Worktree already exists")
      return
    end

    vim.system({ "git", "worktree", "add", input }, { cwd = root }):wait()
    change_working_directory(new_worktree)
    vim.notify("Created worktree " .. new_worktree)
  end)
end

vim.keymap.set("n", "<leader>gw", switch_worktree, { desc = "[g]it switch [w]orktree" })
vim.keymap.set("n", "<leader>wa", add_worktree, { desc = "git [w]orktree [a]dd" })
vim.keymap.set("n", "<leader>wr", remove_worktree, { desc = "git [w]orktree [r]emove" })
