local function is_inside_tmux()
  return os.getenv("TMUX") ~= nil
end

if not is_inside_tmux() then
  return
end

local function open_horizontal_split()
  vim.system({ "tmux", "split-window", "-v", "-c", vim.fn.getcwd() })
end

local function open_vertical_split()
  vim.system({ "tmux", "split-window", "-h", "-c", vim.fn.getcwd() })
end

local function open_popup()
  local data = vim.system({ "basename", os.getenv("PWD") }, { text = true }):wait()
  local name = string.gsub(data.stdout or "popup", "%W", "")
  local command = string.format("tmux popup -w90%% -h90%% -d $PWD -E 'tmux attach -t %s || tmux new -s %s'", name, name)

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

-- terminal
vim.keymap.set("n", "tt", open_horizontal_split, { desc = "[t]mux horizontal split" })
vim.keymap.set("n", "ts", open_horizontal_split, { desc = "[t]mux horizontal split" })
vim.keymap.set("n", "tv", open_vertical_split, { desc = "[t]mux vertical split" })
vim.keymap.set("n", "tp", open_popup, { desc = "[t]mux popup" })

-- git
vim.keymap.set("n", "<leader>gg", open_lazygit, { desc = "[g]it [g]ui" })
