local group = vim.api.nvim_create_augroup("user-terminal-hooks", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
  group = group,
  callback = function()
    vim.opt_local.buflisted = false
    vim.opt_local.bufhidden = "hide"
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})

local function open_term_split()
  vim.cmd.split()
  vim.api.nvim_win_set_height(0, 15)
  vim.cmd.terminal()
end

local function open_term_vsplit()
  vim.cmd.vsplit()
  vim.cmd.terminal()
end

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "exit [t]erminal mode" })
vim.keymap.set("n", "tt", open_term_split, { desc = "open [t]erminal split (horizontal)" })
vim.keymap.set("n", "ts", open_term_split, { desc = "open [t]erminal split (horizontal)" })
vim.keymap.set("n", "tv", open_term_vsplit, { desc = "open [t]erminal split (vertical)" })
