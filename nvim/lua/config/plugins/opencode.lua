---@type opencode.Opts
vim.g.opencode_opts = {}
vim.o.autoread = true

vim.keymap.set({ "n", "x" }, "<leader>aa", function()
  require("opencode").ask("@this: ", { submit = true })
end, { desc = "[a]i [a]sk (this)" })

vim.keymap.set({ "n", "x" }, "<leader>aA", function()
  require("opencode").ask("@buffer: ", { submit = true })
end, { desc = "[a]i [A]sk (buffer)" })

vim.keymap.set({ "n", "x" }, "<leader>ap", function()
  require("opencode").select()
end, { desc = "open [a]i [p]rompt" })

vim.keymap.set({ "n", "t" }, "<leader>at", function()
  require("opencode").toggle()
end, { desc = "[a]i toggle" })
