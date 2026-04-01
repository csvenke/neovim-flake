local workspace = require("config.lib.workspace")

require("no-neck-pain").setup({
  width = 200,
  disableOnLastBuffer = true,
  autocmds = {
    enableOnVimEnter = true,
    enableOnTabEnter = true,
    skipEnteringNoNeckPainBuffer = true,
  },
  buffers = {
    wo = {
      fillchars = "eob: ",
    },
  },
})

vim.keymap.set("n", "<leader>tn", "<cmd>NoNeckPain<cr>", { desc = "[t]oggle no [n]eck pain" })

workspace.register("no-neck-pain", function()
  local nnp = require("no-neck-pain")
  return nnp.state and nnp.state.enabled
end, function()
  pcall(function()
    vim.cmd("NoNeckPain")
  end)
end)

workspace.register_skip("no-neck-pain", function(win_id)
  local bufnr = vim.api.nvim_win_get_buf(win_id)
  local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  return ft == "no-neck-pain"
end)
