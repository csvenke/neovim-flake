local M = {}

---@param directory string
---@return boolean
function M:is_dir(directory)
  return vim.fn.isdirectory(directory) == 1
end

---@param file string
---@return boolean
function M:exists(file)
  return vim.fn.filereadable(file) == 1
end

---@param path string
function M:cwd(path)
  local current_path = vim.fn.expand("%:.")

  vim.cmd("wa")
  vim.cmd("cd " .. path)

  local editable_path = self:exists(current_path) and current_path or "."

  vim.cmd("edit " .. editable_path)
  vim.cmd("delmarks!")
  vim.cmd("clearjumps")
end

---@param from string
---@param to string
function M:copy(from, to)
  if self:is_dir(from) and self:is_dir(to) then
    vim.system({ "cp", "-r", from .. "/.", to }):wait()
  end
end

return M
