require("noice").setup({
  cmdline = {
    view = "cmdline",
  },
  lsp = {
    hover = {
      silent = true,
    },
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
  },
  messages = {
    view = "mini",
    view_error = false,
    view_warn = false,
    view_history = false,
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        any = {
          { find = "Invalid window id" },
          { find = "%d+L, %d+B" },
          { find = "; after #%d+" },
          { find = "; before #%d+" },
        },
      },
      opts = { skip = true },
      view = "mini",
    },
  },
  presets = {
    bottom_search = true,
    long_message_to_split = true,
  },
})

vim.keymap.set("n", "<leader>sl", "<cmd>NoicePick<cr>", { desc = "[s]earch [l]ogs" })
vim.keymap.set("n", "<leader>ls", "<cmd>NoicePick<cr>", { desc = "[l]ogs [s]earch" })
vim.keymap.set("n", "<leader>la", "<cmd>NoiceAll<cr>", { desc = "[l]ogs [a]ll" })
