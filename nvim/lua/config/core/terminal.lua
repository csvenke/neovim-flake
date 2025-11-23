---@class Terminal
---@field buf number|nil
---@field win number|nil

--- @type Terminal[]
local terminals = {}

local function open_term_split()
  vim.cmd.split()
  vim.api.nvim_win_set_height(0, 15)
  vim.cmd.terminal()
end

local function open_term_vsplit()
  vim.cmd.vsplit()
  vim.cmd.terminal()
end

---@param cmd string|nil
---@param id string
---@return Terminal
local function get_or_create_float_term(cmd, id)
  local cwd = vim.fn.getcwd()
  local cache_key = cwd .. (id or "")

  if not terminals[cache_key] then
    terminals[cache_key] = { buf = nil, win = nil }
  end

  local term = terminals[cache_key]

  if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
    return term
  end

  term.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_call(term.buf, function()
    vim.fn.jobstart(cmd or vim.o.shell, {
      term = true,
      cwd = cwd,
      on_exit = function()
        -- Workaround: https://github.com/neovim/neovim/issues/14986
        vim.api.nvim_buf_delete(0, {})
      end,
    })
  end)

  return term
end

---@param term Terminal
local function close_float_window(term)
  if term.win and vim.api.nvim_win_is_valid(term.win) then
    vim.api.nvim_win_close(term.win, true)
    term.win = nil
  end
end

---@param term Terminal
local function open_float_window(term)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2) - 1
  local col = math.floor((vim.o.columns - width) / 2)

  term.win = vim.api.nvim_open_win(term.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  -- Set window-specific highlights for border and background
  vim.api.nvim_set_option_value("winhl", "FloatBorder:FloatTermBorder,Normal:FloatTermNormal", { win = term.win })

  -- Set buffer-local keymap to close with 'q'
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = term.buf, desc = "close" })

  -- Track window closing to update term.win
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(term.win),
    once = true,
    callback = function()
      term.win = nil
    end,
  })
end

---@param term Terminal
---@return boolean
local function is_float_window_open(term)
  return term.win ~= nil and vim.api.nvim_win_is_valid(term.win)
end

---@param cmd string|nil
---@param id string
local function toggle_float_term(cmd, id)
  local term = get_or_create_float_term(cmd, id)

  if is_float_window_open(term) then
    close_float_window(term)
  else
    open_float_window(term)
  end
end

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "exit [t]erminal mode" })

vim.keymap.set("n", "tt", open_term_split, { desc = "open [t]erminal split (horizontal)" })
vim.keymap.set("n", "ts", open_term_split, { desc = "open [t]erminal split (horizontal)" })
vim.keymap.set("n", "tv", open_term_vsplit, { desc = "open [t]erminal split (vertical)" })

vim.keymap.set("n", "tp", function()
  toggle_float_term(nil, ":terminal")
end, { desc = "open [t]erminal [p]opup" })

vim.keymap.set("n", "to", function()
  if vim.fn.executable("opencode") ~= 1 then
    vim.notify("Missing opencode executable")
    return
  end

  toggle_float_term("opencode", ":opencode")
end, { desc = "open [terminal] [o]pencode popup" })

vim.keymap.set("n", "<leader>gg", function()
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("Missing lazygit executable")
    return
  end

  toggle_float_term("lazygit", ":lazygit")
end, { desc = "[g]it [g]ui" })

local group = vim.api.nvim_create_augroup("user-terminal-hooks", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
  group = group,
  callback = function()
    vim.opt_local.buflisted = false
    vim.opt_local.bufhidden = "hide"
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.bo.filetype = "terminal"
    vim.cmd("startinsert!")
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  pattern = "term://*",
  callback = function()
    vim.cmd("startinsert!")
  end,
})
