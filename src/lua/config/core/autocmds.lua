vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("user-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("user-resize-splits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user-close-with-q", { clear = true }),
  pattern = {
    "help",
    "lspinfo",
    "notify",
    "qf",
    "query",
    "startuptime",
    "checkhealth",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = vim.api.nvim_create_augroup("user-auto-create-dir", { clear = true }),
  callback = function(event)
    local is_protocol = event.match:match("^%w%w+:[\\/][\\/]")
    if is_protocol then
      return
    end

    local file = vim.uv.fs_realpath(event.match) or event.match
    local directory_path = vim.fn.fnamemodify(file, ":p:h")
    vim.fn.mkdir(directory_path, "p")
  end,
})

vim.api.nvim_create_autocmd({ "VimEnter", "TabEnter", "TabLeave", "TabNew", "TabClosed" }, {
  group = vim.api.nvim_create_augroup("user-auto-show-tabline", { clear = true }),
  callback = function()
    vim.opt.showtabline = #vim.fn.gettabinfo() > 1 and 2 or 0
  end,
})
