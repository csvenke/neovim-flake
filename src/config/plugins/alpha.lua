local alpha = require("alpha")
local theta = require("alpha.themes.theta")

theta.file_icons.provider = "devicons"

theta.buttons.val = {}

table.insert(theta.config.layout, 1, { type = "padding", val = 15 })

alpha.setup(theta.config)

vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])
