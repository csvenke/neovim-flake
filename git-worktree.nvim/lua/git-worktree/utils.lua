---@param s string
---@param n number
---@return string
local function pad_right(s, n)
  return string.format("%-" .. n .. "s", s)
end

---@param s string
---@param n number
---@return string
local function pad_left(s, n)
  return string.format("%" .. n .. "s", s)
end

local has_devicons, devicons = pcall(require, "nvim-web-devicons")

---@class git-worktree.Icons
---@field git string
---@field get_file_icon fun(filename: string): string, string
local Icons = {
  git = has_devicons and "" or "",
  get_file_icon = function(filename)
    if not has_devicons then
      return "", ""
    end
    local extension = filename:match("^.+%.(.+)$")
    local icon, hl = devicons.get_icon(filename, extension, { default = true })

    return icon or "", hl or ""
  end,
}

return {
  pad_right = pad_right,
  pad_left = pad_left,
  icons = Icons,
}
