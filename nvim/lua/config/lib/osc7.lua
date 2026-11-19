-- Pure OSC 7 (report working directory) helpers that are safe to require anywhere.
local M = {}

-- The host is left empty: herdr ignores OSC 7 unless the host is empty or "localhost".
---@param path string
---@return string
function M.build(path)
  local encoded = path:gsub("[^%w/%._~%-]", function(char)
    return string.format("%%%02X", char:byte())
  end)
  return "\27]7;file://" .. encoded .. "\27\\"
end

return M
