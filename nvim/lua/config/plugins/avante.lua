require("render-markdown").setup({
  file_types = { "Avante" },
  latex = {
    enabled = false,
  },
  heading = {
    backgrounds = {},
  },
})
require("avante").setup({
  mode = "agentic",
  provider = "claude",
  providers = {
    claude = {
      endpoint = "https://api.anthropic.com",
      model = "claude-sonnet-4-20250514",
      extra_request_body = {
        temperature = 0,
        max_tokens = 4096,
      },
    },
  },
  disabled_tools = { "web_search", "rag_search", "python" },
  behaviour = {
    use_cwd_as_project_root = true,
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
