require("fyler").setup({
  close_on_select = false,
  confirm_simple = true,
  icon_provider = "nvim_web_devicons",
  indentscope = {
    enabled = false,
  },
  mappings = {
    ["l"] = "Select",
    ["h"] = "CollapseNode",
    ["-"] = "GotoParent",
    ["_"] = "GotoCwd",
    ["."] = "GotoNode",
    ["q"] = "CloseView",
    ["t"] = "SelectTab",
    ["v"] = "SelectVSplit",
    ["s"] = "SelectSplit",
  },
  win = {
    kind = "split_left_most",
    kind_presets = {
      split_left_most = {
        width = "0.2rel",
      },
    },
    win_opts = {
      winfixwidth = true,
      number = false,
      relativenumber = false,
      signcolumn = "yes:1",
      foldcolumn = "0",
    },
  },
})

vim.keymap.set("n", "<leader>e", function()
  require("fyler").toggle()
  vim.api.nvim_exec_autocmds("VimResized", {})
end, { desc = "file [e]xplorer" })
