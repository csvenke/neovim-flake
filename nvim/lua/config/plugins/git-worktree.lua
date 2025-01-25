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

---@param path string
local function change_working_directory(path)
  local current_path = vim.fn.expand("%:.")
  local editable_path = vim.fn.filereadable(current_path) == 1 and current_path or "."

  vim.cmd("wa")
  vim.cmd("clearjumps")

  vim.lsp.stop_client(vim.lsp.get_clients(), true)

  vim.cmd("cd " .. path)
  vim.cmd("edit " .. editable_path)

  vim.defer_fn(function()
    vim.cmd("LspRestart")
    vim.cmd("e!")
  end, 200)
end

local function switch_worktree()
  select_worktree("Switch worktree", function(worktree)
    if vim.fn.getcwd() == worktree then
      return
    end

    change_working_directory(worktree)
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

    local root_worktree = get_root_worktree()
    local new_worktree = string.format("%s/%s", root_worktree, input)

    if vim.fn.isdirectory(new_worktree) == 1 then
      vim.notify("Worktree already exists")
      return
    end

    vim.system({ "git", "worktree", "add", input }, { cwd = root_worktree }):wait()

    copy_shared(root_worktree, new_worktree)
    direnv_setup(new_worktree)
    change_working_directory(new_worktree)

    vim.notify("Switched to worktree " .. new_worktree)
  end)
end

vim.keymap.set("n", "<leader>gw", switch_worktree, { desc = "[g]it switch [w]orktree" })
vim.keymap.set("n", "<leader>wa", add_worktree, { desc = "git [w]orktree [a]dd" })
vim.keymap.set("n", "<leader>wr", remove_worktree, { desc = "git [w]orktree [r]emove" })
