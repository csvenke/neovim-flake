local M = {}

---@param s string
---@param n number
function M.pad_right(s, n)
  return string.format("%-" .. n .. "s", s)
end

---@param s string
---@param n number
function M.pad_left(s, n)
  return string.format("%" .. n .. "s", s)
end

return M
