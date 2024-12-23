local alpha = require("alpha")
local theta = require("alpha.themes.theta")

theta.file_icons.provider = "devicons"

theta.buttons.val = {}

alpha.setup(theta.config)

vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])
