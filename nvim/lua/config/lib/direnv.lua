local Path = require("config.lib.path")

local M = {}

---@param path string
function M.is_available(path)
  local has_direnv = vim.fn.executable("direnv") == 1
  local has_envrc = Path.is_file(path .. "/.envrc")
  return has_direnv and has_envrc
end

---@param path string
function M.allow_if_available(path)
  if not M.is_available(path) then
    return
  end

  vim.system({ "direnv", "allow", path }):wait()
end

return M
