local M = {}

---@param path string
function M.cwd(path)
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

---@param from string
---@param to string
function M.copy(from, to)
  if vim.fn.isdirectory(from) == 0 then
    return
  end
  if vim.fn.isdirectory(to) == 0 then
    return
  end
  vim.system({ "cp", "-r", from .. "/.", to }):wait()
end

return M
