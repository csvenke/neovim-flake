require("avante").setup({
  mode = "agentic",
  provider = "claude",
  providers = {
    claude = {
      endpoint = "https://api.anthropic.com",
      model = "claude-3-7-sonnet-latest",
      disabled_tools = { "web_search" },
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
