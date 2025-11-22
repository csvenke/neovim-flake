require("toggleterm").setup({
  start_in_insert = true,
  persist_mode = false,
  float_opts = {
    width = function()
      return math.floor(vim.o.columns * 0.8)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.8)
    end,
  },
})

---@type Terminal[]
local terminals = {}

---@param cmd string|nil
---@param id string
---@return Terminal
local function create_float_term(cmd, id)
  local cwd = vim.fn.getcwd()
  local cache_key = cwd .. (id or "")

  if terminals[cache_key] then
    return terminals[cache_key]
  end

  local Terminal = require("toggleterm.terminal").Terminal

  local term = Terminal:new({
    cmd = cmd,
    dir = cwd,
    direction = "float",
    on_open = function(term)
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = term.bufnr, desc = "close" })
    end,
  })

  terminals[cache_key] = term

  return term
end

vim.keymap.set("n", "tp", function()
  local term = create_float_term(nil, ":term")
  term:toggle()
end, { desc = "[t]erminal [p]opup" })

vim.keymap.set("n", "to", function()
  if not vim.fn.executable("opencode") == 1 then
    vim.notify("Missing opencode executable")
    return
  end

  local term = create_float_term("opencode", ":opencode")
  term:toggle()
end, { desc = "[t]erminal popup [o]pencode" })

vim.keymap.set("n", "<leader>gg", function()
  if not vim.fn.executable("lazygit") == 1 then
    vim.notify("Missing lazygit executable")
    return
  end

  local term = create_float_term("lazygit", ":lazygit")
  term:toggle()
end, { desc = "[g]it [g]ui" })
