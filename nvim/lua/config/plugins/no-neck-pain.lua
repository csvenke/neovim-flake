require("no-neck-pain").setup({
  width = 150,
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
