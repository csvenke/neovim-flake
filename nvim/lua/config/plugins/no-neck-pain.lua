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
