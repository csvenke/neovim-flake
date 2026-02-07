-- Minimal init for testing git-worktree.nvim

-- Add the plugin to the runtimepath
vim.opt.runtimepath:prepend(vim.fn.getcwd() .. "/git-worktree.nvim")

-- Set up minimal test environment
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Load the plugin
require("git-worktree").setup({
  notify = false,  -- Disable notifications in tests
})
