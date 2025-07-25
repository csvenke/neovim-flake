local wk = require("which-key")

wk.add({
  { "<leader>a", group = "ai", mode = { "n", "v" } },
  { "<leader>b", group = "buffer" },
  { "<leader>d", group = "debug" },
  { "<leader>D", group = "Database" },
  { "<leader>g", group = "git" },
  { "<leader>q", group = "quit" },
  { "<leader>s", group = "search" },
  { "<leader>t", group = "test" },
  { "<leader>w", group = "git worktree" },
  { "<leader>l", group = "logs" },
})
