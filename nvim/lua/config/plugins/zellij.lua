local Git = require("config.lib.git")
local icons = require("config.lib.icons")

local function is_zellij()
  return vim.env.ZELLIJ ~= nil
end

---@param name string
local function rename_tab(name)
  vim.system({ "zellij", "action", "rename-tab", name }):wait()
end

local function undo_rename_tab()
  vim.system({ "zellij", "action", "undo-rename-tab" }):wait()
end

local function rename_tab_to_worktree()
  local worktree = Git.get_bare_worktree(Git.worktree_list())
  if worktree ~= nil then
    rename_tab(icons.term .. " " .. worktree.name)
  end
end

local function setup()
  if not is_zellij() then
    return
  end

  local group = vim.api.nvim_create_augroup("user-zellij-hooks", { clear = true })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    callback = function()
      vim.schedule(function()
        rename_tab_to_worktree()
      end)
    end,
  })

  vim.api.nvim_create_autocmd("VimLeave", {
    group = group,
    once = true,
    callback = function()
      vim.schedule(function()
        undo_rename_tab()
      end)
    end,
  })
end

setup()
