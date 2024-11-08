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
  local command = string.format("tmux popup -d $PWD -E 'tmux attach -t %s || tmux new -s %s'", name, name)

  os.execute(command)
end

vim.keymap.set("n", "tt", open_horizontal_split, { desc = "[t]mux horizontal split" })
vim.keymap.set("n", "ts", open_horizontal_split, { desc = "[t]mux horizontal split" })
vim.keymap.set("n", "tv", open_vertical_split, { desc = "[t]mux vertical split" })
vim.keymap.set("n", "tp", open_popup, { desc = "[t]mux popup" })
