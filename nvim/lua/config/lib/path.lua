-- Filesystem helpers only. Editor/workspace transitions live under config.runtime.
local M = {}

---@param path string
local function stat(path)
  return vim.uv.fs_stat(vim.fs.normalize(path))
end

---@param directory string
function M.is_directory(directory)
  local directory_stat = stat(directory)
  return directory_stat ~= nil and directory_stat.type == "directory"
end

---@param file string
function M.is_file(file)
  local file_stat = stat(file)
  return file_stat ~= nil and file_stat.type == "file"
end

---@param from string
---@param to string
function M.copy_directory(from, to)
  if not M.is_directory(from) then
    return
  end
  if not M.is_directory(to) then
    return
  end

  vim.system({ "cp", "-r", vim.fs.joinpath(from, "."), to }):wait()
end

return M
