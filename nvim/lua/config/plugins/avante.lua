require("avante").setup({
  mode = "agentic",
  provider = "claude",
  providers = {
    claude = {
      endpoint = "https://api.anthropic.com",
      model = "claude-sonnet-4-20250514",
    },
  },
  windows = {
    position = "smart",
    edit = {
      start_insert = false,
    },
    ask = {
      floating = true,
      start_insert = false,
    },
  },
})
