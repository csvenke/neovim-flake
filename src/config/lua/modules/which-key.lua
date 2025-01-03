local wk = require("which-key")

wk.add({
  {
    mode = { "n", "v" },
    { "<leader>a", group = "[a]i" },
  },
  { "<leader>b", group = "[b]uffer" },
  {
    mode = { "n", "x" },
    { "<leader>c", group = "[c]ode" },
  },
  { "<leader>d", group = "[d]ebug" },
  { "<leader>g", group = "[g]it" },
  { "<leader>q", group = "[q]uit" },
  { "<leader>s", group = "[s]earch" },
  { "<leader>t", group = "[t]est" },
  { "<leader>l", group = "logs" },
})
