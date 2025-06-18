local group = vim.api.nvim_create_augroup("user-core-hooks", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  callback = function()
    vim.cmd("wincmd =")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "help",
    "lspinfo",
    "notify",
    "qf",
    "query",
    "startuptime",
    "checkhealth",
  },
  group = group,
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = group,
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
  group = group,
  callback = function()
    vim.opt.showtabline = #vim.fn.gettabinfo() > 1 and 2 or 0
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = group,
  command = "silent! checktime",
})

vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  group = group,
  command = "silent! wa",
})

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = "*",
  group = group,
  callback = function()
    vim.cmd("rightbelow copen")
  end,
})
