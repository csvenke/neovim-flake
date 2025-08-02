local group = vim.api.nvim_create_augroup("user-terminal-hooks", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
  group = group,
  callback = function()
    vim.opt_local.buflisted = false
    vim.opt_local.bufhidden = "hide"
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.bo.filetype = "terminal"
    vim.cmd("startinsert")
  end,
})

local function create_job(cmd)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)

  local job_id = vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, {})
        end
      end)
    end,
  })

  return job_id
end

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

---@param cmd string
---@return function
local function claude(cmd)
  return function()
    if vim.fn.executable("claude") == 0 then
      vim.notify("claude code not installed")
      return
    end
    open_term_vsplit()
    create_job(cmd)
    vim.bo.filetype = "claude"
  end
end

vim.keymap.set("n", "<leader>aa", claude("claude -c || claude"), { desc = "[a]i toggle chat" })
vim.keymap.set("n", "<leader>at", claude("claude -c || claude"), { desc = "[a]i toggle chat" })
vim.keymap.set("n", "<leader>an", claude("claude"), { desc = "[a]i [n]ew chat" })
