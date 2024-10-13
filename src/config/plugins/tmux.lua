local function is_inside_tmux()
  return os.getenv("TMUX") ~= nil
end

if not is_inside_tmux() then
  return
end

local function open_horizontal_split()
  os.execute("tmux split-window -v -c $PWD")
end

local function open_vertical_split()
  os.execute("tmux split-window -h -c $PWD")
end

local function open_popup()
  os.execute("tmux popup -d $PWD -E 'tmux attach -t popup || tmux new -s popup'")
end

vim.keymap.set("n", "tt", open_horizontal_split, { desc = "[t]mux horizontal split" })
vim.keymap.set("n", "ts", open_horizontal_split, { desc = "[t]mux horizontal split" })
vim.keymap.set("n", "tv", open_vertical_split, { desc = "[t]mux vertical split" })
vim.keymap.set("n", "tp", open_popup, { desc = "[t]mux popup" })
