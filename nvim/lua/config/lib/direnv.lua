local Path = require("config.lib.path")

local M = {}

---@param path string
function M:allow(path)
  local has_direnv = vim.fn.executable("direnv") == 1
  local has_envrc = Path:exists(path .. "/.envrc")

  if has_direnv and has_envrc then
    vim.system({ "direnv", "allow", path }):wait()
  end
end

return M
