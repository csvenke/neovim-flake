local M = {}

--- @param buffer number
function M.make_map_buffer(buffer)
  --- @param keys string
  --- @param func fun()
  --- @param desc? string
  --- @param mode? string|table
  return function(keys, func, desc, mode)
    mode = mode or "n"
    desc = desc or ""
    vim.keymap.set(mode, keys, func, { buffer = buffer, desc = desc })
  end
end

--- @param name string
function M.make_code_action(name)
  return function()
    vim.lsp.buf.code_action({
      apply = true,
      context = {
        only = { name },
        diagnostics = {},
      },
    })
  end
end

---@return string[]
function M.git_worktree_list()
  local output = vim.fn.system("git worktree list")
  local worktrees = vim.split(output, "\n", { trimempty = true })
  return worktrees
end

---@return string[]
function M.get_worktrees()
  local worktrees = M.git_worktree_list()
  table.remove(worktrees, 1)
  return worktrees
end

---@return string
function M.get_root_worktree()
  local worktrees = M.git_worktree_list()
  local first = table.remove(worktrees, 1)
  return first:match("^%S+")
end

---@param path string
function M.change_working_directory(path)
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

return M
