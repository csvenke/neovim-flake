---@return string[]
local function git_worktree_list()
  local output = vim.system({ "git", "worktree", "list" }):wait()
  local worktrees = vim.split(output.stdout, "\n", { trimempty = true })
  return worktrees
end

---@return string
local function git_worktree_root()
  local worktrees = git_worktree_list()
  local first = table.remove(worktrees, 1)
  return first:match("^%S+")
end

---@param name string
---@param callback fun(root: string, path: string)
local function git_worktree_add(name, callback)
  local root_path = git_worktree_root()
  local worktree_path = string.format("%s/%s", root_path, name)

  if vim.fn.isdirectory(worktree_path) == 1 then
    vim.notify("Worktree already exists")
    return
  end

  vim.system({ "git", "worktree", "add", name }, { cwd = root_path }):wait()

  if vim.fn.isdirectory(worktree_path) == 0 then
    vim.notify("Failed to add worktree " .. worktree_path)
    return
  end

  callback(root_path, worktree_path)
end

---@param prompt string
---@param on_select fun(path: string)
local function select_worktree(prompt, on_select)
  local worktrees = git_worktree_list()
  table.remove(worktrees, 1)

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

  if vim.bo.modified then
    vim.cmd("wa")
  end

  vim.cmd("cd " .. path)
  vim.cmd("clearjumps")

  for _, client in ipairs(vim.lsp.get_clients()) do
    vim.lsp.stop_client(client.id)
  end

  vim.cmd("edit " .. editable_path)
end

local function switch_worktree()
  select_worktree("Switch worktree", function(worktree)
    change_working_directory(worktree)
    vim.notify_once("Switched to worktree " .. worktree)
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
      vim.notify("Failed to remove worktree " .. worktree)
    else
      vim.notify("Removed worktree " .. worktree)
    end
  end)
end

local function add_worktree()
  vim.ui.input({
    prompt = "Create worktree",
  }, function(input)
    if input == nil then
      return
    end

    ---@param root_path string
    ---@param worktree_path string
    local function copy_from_shared(root_path, worktree_path)
      local shared_dir = root_path .. "/.shared"
      if vim.fn.isdirectory(shared_dir) == 1 then
        vim.system({ "cp", "-r", shared_dir .. "/.", worktree_path }):wait()
      end
    end

    ---@param worktree_path string
    local function direnv_allow(worktree_path)
      local has_direnv = vim.fn.executable("direnv")
      local has_envrc = vim.fn.filereadable(worktree_path .. "/.envrc") == 1
      if has_direnv and has_envrc then
        vim.system({ "direnv", "allow", worktree_path }):wait()
      end
    end

    git_worktree_add(input, function(root_path, worktree_path)
      copy_from_shared(root_path, worktree_path)
      direnv_allow(worktree_path)
      change_working_directory(worktree_path)

      vim.notify_once("Switched to worktree " .. worktree_path)
    end)
  end)
end

vim.keymap.set("n", "<leader>gw", switch_worktree, { desc = "[g]it switch [w]orktree" })
vim.keymap.set("n", "<leader>ws", switch_worktree, { desc = "[g]it switch [w]orktree" })
vim.keymap.set("n", "<leader>wa", add_worktree, { desc = "git [w]orktree [a]dd" })
vim.keymap.set("n", "<leader>wr", remove_worktree, { desc = "git [w]orktree [r]emove" })
