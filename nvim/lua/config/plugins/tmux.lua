local Git = require("config.lib.git")

local function is_inside_tmux()
  return os.getenv("TMUX") ~= nil
end

if not is_inside_tmux() then
  return
end

local function open_popup()
  ---@param name string
  local function parse_name(name)
    local parsed = string.gsub(name, "%W", "")
    return parsed
  end
  local function get_popup_name()
    local worktrees = Git.worktree_list()

    if #worktrees > 1 then
      local bare_worktree = Git.get_bare_worktree(worktrees)
      local active_worktree = Git.get_active_worktree(worktrees)

      if bare_worktree and active_worktree then
        local parts = {}

        table.insert(parts, parse_name(bare_worktree.name))
        table.insert(parts, "popup")

        if bare_worktree.name ~= active_worktree.name then
          table.insert(parts, parse_name(active_worktree.name))
        end

        return table.concat(parts, "_")
      end
    end

    local directory_name = vim.fs.basename(vim.fn.getcwd())

    if directory_name then
      local parts = {}
      table.insert(parts, parse_name(directory_name))
      table.insert(parts, "popup")
      return table.concat(parts, "_")
    end

    return "popup"
  end

  local popup_name = get_popup_name()
  local command =
    string.format("tmux popup -w90%% -h90%% -d $PWD -E 'tmux attach -t %s || tmux new -s %s'", popup_name, popup_name)

  vim.cmd("wa")
  os.execute(command)
  vim.cmd("checktime")
end

local function open_lazygit()
  if vim.fn.executable("lazygit") == 0 then
    vim.notify("Lazygit not installed")
    return
  end

  vim.cmd("wa")
  os.execute("tmux popup -w100% -h100% -d $PWD -E 'lazygit'")
  vim.cmd("checktime")
end

vim.keymap.set("n", "tp", open_popup, { desc = "[t]mux popup" })
vim.keymap.set("n", "<leader>gg", open_lazygit, { desc = "[g]it [g]ui" })
