---@param text string
---@param hl string
local function create_header(text, hl)
  return {
    type = "text",
    val = text,
    opts = { position = "center", hl = hl },
  }
end

---@param lines integer
local function create_padding(lines)
  return { type = "padding", val = lines }
end

---@param worktrees Worktree[]
local function create_worktrees_group(worktrees)
  local icon = "󰊢"
  local icon_hl = "AlphaGitIcon"
  local header = "Git worktrees"
  local header_hl = "SpecialComment"
  local shortcuts = { "q", "w", "e", "r", "a", "s", "d", "f", "z", "x", "c", "v" }
  local dashboard = require("alpha.themes.dashboard")

  local elements = {
    create_header(header, header_hl),
    create_padding(1),
  }

  for i, worktree in ipairs(worktrees) do
    local shortcut = shortcuts[i] or "-"

    local keybind = string.format("<cmd>cd %s | edit .<cr>", worktree.path)
    local text = string.format("%s  %s", icon, worktree.name)
    local button = dashboard.button(shortcut, text, keybind)
    button.opts.hl = {
      { icon_hl, 0, #icon },
    }

    table.insert(elements, button)
  end

  return {
    type = "group",
    val = elements,
    opts = { position = "center" },
  }
end

local function setup()
  local alpha = require("alpha")
  local theta = require("alpha.themes.theta")

  -- Remove default buttons
  theta.buttons.val = {}

  -- Add git worktree section
  local worktrees = require("config.lib.git").get_worktrees()
  if #worktrees > 0 then
    table.insert(theta.config.layout, 3, create_padding(2))
    table.insert(theta.config.layout, 4, create_worktrees_group(worktrees))
  end

  alpha.setup(theta.config)

  local group = vim.api.nvim_create_augroup("user-alpha-hooks", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "alpha",
    callback = function()
      vim.opt_local.foldenable = false
    end,
  })
end

setup()
