local has_devicons, devicons = pcall(require, "nvim-web-devicons")

---@class Icons
---@field git string
---@field dir string
---@field startuptime string
---@field separator string
---@field modified string
---@field tag string
---@field diagnostic_error string
---@field diagnostic_warn string
---@field diagnostic_info string
---@field diagnostic_hint string
---@field dap_breakpoint string
---@field dap_breakpoint_condition string
---@field dap_breakpoint_rejected string
---@field dap_logpoint string
---@field dap_stopped string
---@field get_file_icon fun(filename: string): string, string

---@type Icons
local M = {
  git = has_devicons and "󰊢" or "",
  dir = has_devicons and "" or "",
  startuptime = has_devicons and "󱐋" or "",
  separator = has_devicons and "󰅂" or ">",
  modified = has_devicons and "●" or "[+]",
  tag = has_devicons and "󰓹" or "#",
  diagnostic_error = has_devicons and "󰅚" or "E",
  diagnostic_warn = has_devicons and "󰀪" or "W",
  diagnostic_info = has_devicons and "󰋽" or "I",
  diagnostic_hint = has_devicons and "󰌶" or "H",
  dap_breakpoint = has_devicons and "●" or "*",
  dap_breakpoint_condition = has_devicons and "⊜" or "?",
  dap_breakpoint_rejected = has_devicons and "⊘" or "x",
  dap_logpoint = has_devicons and "◆" or "o",
  dap_stopped = has_devicons and "|>" or ">",
  get_file_icon = function(filename)
    if not has_devicons then
      return "", ""
    end
    local extension = filename:match("^.+%.(.+)$")
    local icon, hl = devicons.get_icon(filename, extension, { default = true })

    return icon or "", hl or ""
  end,
}

return M
