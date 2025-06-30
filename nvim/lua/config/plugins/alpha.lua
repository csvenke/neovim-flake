local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
local theta = require("alpha.themes.theta")
local Git = require("config.lib.git")

theta.file_icons.provider = "devicons"
theta.buttons.val = {}

local worktrees = Git.get_worktrees()

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

  for i, worktree in ipairs(worktrees) do
    local git_icon = "󰊢"
    local worktree_shortcut = shortcuts[i] or "-"
    local keybind = string.format("<cmd>cd %s | edit .<cr>", worktree.path)
    local text = string.format("%s  %s", git_icon, worktree.name)
    local button = dashboard.button(worktree_shortcut, text, keybind)

    button.opts.hl = {
      { "AlphaGitIcon", 0, #git_icon },
    }

    table.insert(val, button)
  end

  table.insert(theta.config.layout, 3, {
    type = "padding",
    val = 2,
  })
  table.insert(theta.config.layout, 4, {
    type = "group",
    val = val,
    opts = {
      position = "center",
    },
  })
end

alpha.setup(theta.config)

local group = vim.api.nvim_create_augroup("user-alpha-hooks", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  group = group,
  callback = function()
    vim.api.nvim_set_hl(0, "AlphaGitIcon", { fg = "#d08770" })
  end,
})

vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])
