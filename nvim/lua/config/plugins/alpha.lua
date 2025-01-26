local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
local theta = require("alpha.themes.theta")
local util = require("config.util")

theta.file_icons.provider = "devicons"

theta.buttons.val = {}

local worktrees = util.get_worktrees()

if not vim.tbl_isempty(worktrees) then
  local shortcuts = { "q", "w", "e", "r", "a", "s", "d", "f", "z", "x", "c", "v" }
  local val = {}

  table.insert(val, {
    type = "text",
    val = "Git worktrees",
    opts = {
      position = "center",
      hl = "SpecialComment",
    },
  })
  table.insert(val, { type = "padding", val = 1 })

  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      vim.api.nvim_set_hl(0, "AlphaGitIcon", { fg = "#d08770" })
    end,
  })

  for i, worktree in ipairs(worktrees) do
    local path = worktree:match("^%S+")
    local shortcut = shortcuts[i] or "-"
    local icon = "󰊢"
    local text = string.format("%s %s", icon, path)
    local keybind = string.format("<cmd>cd %s | edit .<cr>", path)
    local button = dashboard.button(shortcut, text, keybind)
    button.opts.hl = {
      { "AlphaGitIcon", 0, #icon },
    }

    table.insert(val, button)
  end

  table.insert(theta.config.layout, 3, { type = "padding", val = 2 })
  table.insert(theta.config.layout, 4, {
    type = "group",
    val = val,
    opts = {
      position = "center",
    },
  })
end

alpha.setup(theta.config)

vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])
