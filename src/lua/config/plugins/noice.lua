require("noice").setup({
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
          { find = "%d+L, %d+B" },
          { find = "; after #%d+" },
          { find = "; before #%d+" },
        },
      },
      view = "mini",
    },
  },
  presets = {
    bottom_search = false,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = true,
    lsp_doc_border = false,
  },
})

vim.keymap.set("n", "<leader>sl", "<cmd>NoicePick<cr>", { desc = "[s]earch [l]ogs" })
vim.keymap.set("n", "<leader>ls", "<cmd>NoicePick<cr>", { desc = "[l]ogs [s]earch" })
vim.keymap.set("n", "<leader>la", "<cmd>NoiceAll<cr>", { desc = "[l]ogs [a]ll" })
