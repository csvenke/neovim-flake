local function git_worktree_list()
  local output = vim.fn.system("git worktree list")
  local worktrees = vim.split(output, "\n", { trimempty = true })
  table.remove(worktrees, 1)
  return worktrees
end

---@class SelectWorktreeOpts
---@field prompt string
---@field on_select fun(path: string)
---@field on_empty fun()
---@param opts SelectWorktreeOpts
local function select_worktree(opts)
  local worktrees = git_worktree_list()

  if #worktrees == 0 then
    opts.on_empty()
    return
  end

  vim.ui.select(worktrees, {
    prompt = opts.prompt,
  }, function(choice)
    if choice ~= nil then
      local path = choice:match("^%S+")
      opts.on_select(path)
    end
  end)
end

---@param file string
local function get_readable_file(file)
  return vim.fn.filereadable(file) == 1 and file or "."
end

local function git_switch_worktree()
  select_worktree({
    prompt = "Switch worktree",
    on_select = function(worktree_path)
      local current_path = vim.fn.expand("%:.")
      vim.cmd("cd " .. worktree_path)
      vim.cmd("clearjumps")
      vim.cmd("edit " .. get_readable_file(current_path))
    end,
    on_empty = function()
      vim.notify("No worktrees found")
    end,
  })
end

vim.keymap.set("n", "<leader>gw", git_switch_worktree, { desc = "[g]it switch [w]orktree" })
