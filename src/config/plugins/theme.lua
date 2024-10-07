require("nordic").setup({
  on_highlight = function(highlights, palette)
    highlights.NeoTreeTitleBar = { fg = palette.yellow.dim }
    highlights.NeoTreeGitUntracked = { fg = palette.white0 }
  end,
})

vim.cmd.colorscheme("nordic")
