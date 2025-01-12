local wk = require("which-key")

wk.add({
  {
    mode = { "n" },
    { "<C-t>", group = "+tab" },
  },
  {
    mode = { "n", "v" },
    { "<leader>a", group = "ai" },
  },
  { "<leader>b", group = "buffer" },
  {
    mode = { "n", "v" },
    { "<leader>c", group = "code" },
  },
  { "<leader>d", group = "debug" },
  { "<leader>g", group = "git" },
  { "<leader>q", group = "quit" },
  { "<leader>s", group = "search" },
  { "<leader>t", group = "test" },
  { "<leader>w", group = "git worktree" },
  { "<leader>l", group = "logs" },
})
