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
