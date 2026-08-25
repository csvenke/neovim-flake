vim.g.diffs = {
  integrations = {
    fugitive = true,
    gitsigns = true,
    telescope = true,
  },
  highlights = {
    warn_max_lines = false,
    treesitter = { max_lines = 2000 },
    vim = { max_lines = 1000 },
    intra = { max_lines = 2000 },
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

local notify = require("config.lib.notify")
local opencode = require("config.lib.opencode")

local NOTIFY_TITLE = "OpenCode"

local function draft_commit_message()
  if vim.system({ "git", "diff", "--staged", "--quiet" }):wait().code == 0 then
    notify.with_title(NOTIFY_TITLE)("Nothing staged to commit", vim.log.levels.WARN)
    return
  end

  local progress = notify.progress(NOTIFY_TITLE, "Drafting commit message...")

  opencode.run({
    agent = "build",
    model = "github-copilot/claude-haiku-4.5",
    message = "Use the draft-commit skill to write a commit message for the staged changes. "
      .. "Output ONLY the raw commit message.",
  }, function(msg, err)
    if not msg then
      progress.fail(err)
      return
    end
    progress.done()

    msg = vim.trim(msg):gsub("^```%w*\n", ""):gsub("\n```%s*$", "")
    vim.cmd("Git commit")
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].filetype == "gitcommit" and vim.api.nvim_buf_is_loaded(buf) then
        vim.api.nvim_buf_set_lines(buf, 0, 0, false, vim.split(msg, "\n"))
        return
      end
    end
  end)
end

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "fugitive",
  callback = function(ev)
    vim.keymap.set("n", "<leader>cc", draft_commit_message, {
      buffer = ev.buf,
      desc = "[g]it AI [c]ommit message",
    })
  end,
})
