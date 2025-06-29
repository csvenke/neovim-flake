-- Leader key configuration
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- General editor behavior
vim.g.autoformat = false
vim.opt.autowrite = true
vim.opt.autowriteall = true
vim.opt.autoread = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.confirm = false
vim.opt.cursorbind = false

-- Clipboard configuration
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Line numbers and UI display
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 10
vim.opt.scrollbind = false

-- Search and completion settings
vim.opt.hlsearch = true
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.inccommand = "split"
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Indentation and formatting
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.wrap = false

-- Special characters display
vim.opt.list = true
vim.opt.listchars = {
  tab = "  ",
  trail = "·",
  nbsp = "␣",
  extends = "›",
  precedes = "‹",
}

-- Split behavior
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Error bells
vim.opt.errorbells = false
vim.opt.visualbell = false

-- Disable swap files
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Disable external file change warnings
vim.opt.readonly = false

-- Filetypes
vim.filetype.add({
  pattern = {
    [".*%.component%.html"] = "htmlangular",
  },
})
