-- Git Worktree Configuration
-- Uses git-worktree.nvim plugin

require("git-worktree").setup({
  keymaps = {
    switch = "<leader>gw",
    add = "<leader>wa",
    remove = "<leader>wr",
  },
  hooks = {
    after_add = ".hooks/after-worktree-add.sh",
  },
  enable_direnv = true,
  copy_shared = ".shared",
  notify = true,
})
