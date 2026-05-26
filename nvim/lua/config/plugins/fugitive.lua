vim.g.diffs = {
  integrations = {
    fugitive = true,
    gitsigns = true,
    telescope = true,
  },
}

vim.keymap.set("n", "<leader>gg", "<cmd>rightbelow Git<cr>", { desc = "[g]it [s]tatus" })
vim.keymap.set("n", "<leader>gs", "<cmd>rightbelow Git<cr>", { desc = "[g]it [s]tatus" })
vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit<cr>", { desc = "[g]it [d]iff" })
vim.keymap.set("n", "<leader>gD", "<cmd>leftabove Gvdiffsplit origin/HEAD<cr>", { desc = "[g]it [D]iff" })
vim.keymap.set("n", "<leader>gh", "<cmd>tabnew % | rightbelow 0Gclog<cr>", { desc = "[g]it [h]istory" })
vim.keymap.set("n", "<leader>gH", "<cmd>tabnew % | rightbelow Gclog<cr>", { desc = "[g]it [H]istory" })
vim.keymap.set("n", "<leader>gt", "<cmd>rightbelow Git difftool<cr>", { desc = "[g]it diff[t]ool" })
vim.keymap.set("n", "<leader>gT", "<cmd>rightbelow Git difftool origin/HEAD<cr>", { desc = "[g]it diff[T]ool" })

local group = vim.api.nvim_create_augroup("user-fugitive-hooks", { clear = true })

---@param bufnr number
local function is_fugitive_buffer(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return vim.bo[bufnr].filetype == "fugitive" or name:match("^fugitive://") ~= nil
end

local function clean_diff_window()
  if not vim.wo.diff then
    return
  end

  vim.opt_local.fillchars:append({ diff = " " })
  vim.opt_local.foldmethod = "manual"
  vim.opt_local.foldenable = false
  vim.opt_local.foldcolumn = "0"
  vim.opt_local.cursorline = false
  vim.opt_local.cursorcolumn = false
  vim.wo.winhighlight = "CursorLine:Normal,Folded:Normal,FoldColumn:Normal"

  if is_fugitive_buffer(0) then
    vim.opt_local.readonly = true
    vim.opt_local.modifiable = false
  end
end

vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
  group = group,
  callback = clean_diff_window,
})

vim.api.nvim_create_autocmd("OptionSet", {
  group = group,
  pattern = "diff",
  callback = clean_diff_window,
})
