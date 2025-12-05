local popup = require("config.lib.popup")

local function open_term_split()
  vim.cmd.split()
  vim.api.nvim_win_set_height(0, 15)
  vim.cmd.terminal()
end

local function open_term_vsplit()
  vim.cmd.vsplit()
  vim.cmd.terminal()
end

local function open_popup()
  popup.toggle({ id = ":terminal", width = 0.5, height = 0.5 })
end

local function open_lazygit_popup()
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("Missing lazygit executable")
    return
  end
  popup.toggle({ id = ":lazygit", cmd = "lazygit", width = 0.8, height = 0.8 })
end

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "exit [t]erminal mode" })
vim.keymap.set("n", "tt", open_term_split, { desc = "open [t]erminal split (horizontal)" })
vim.keymap.set("n", "ts", open_term_split, { desc = "open [t]erminal split (horizontal)" })
vim.keymap.set("n", "tv", open_term_vsplit, { desc = "open [t]erminal split (vertical)" })
vim.keymap.set("n", "tp", open_popup, { desc = "open [t]erminal [p]opup" })
vim.keymap.set("n", "<leader>gg", open_lazygit_popup, { desc = "[g]it [g]ui" })

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

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "terminal",
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>close!<cr>", { buffer = args.buf, desc = "close popup" })
    vim.keymap.set("t", "<C-q>", "<cmd>close!<cr>", { buffer = args.buf, desc = "close popup" })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  pattern = "term://*",
  callback = function()
    vim.cmd("startinsert!")
  end,
})
