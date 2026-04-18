local dap = require("dap")
local dapview = require("dap-view")
local widgets = require("dap.ui.widgets")
local icons = require("config.lib.icons")
require("nvim-dap-virtual-text").setup({})

vim.fn.sign_define("DapBreakpoint", {
  text = icons.dap_breakpoint,
  texthl = "DapBreak",
  numhl = "DapBreak",
})
vim.fn.sign_define("DapBreakpointCondition", {
  text = icons.dap_breakpoint_condition,
  texthl = "DapBreak",
  numhl = "DapBreak",
})
vim.fn.sign_define("DapBreakpointRejected", {
  text = icons.dap_breakpoint_rejected,
  texthl = "DapBreak",
  numhl = "DapBreak",
})
vim.fn.sign_define("DapLogPoint", {
  text = icons.dap_logpoint,
  texthl = "DapBreak",
  numhl = "DapBreak",
})
vim.fn.sign_define("DapStopped", {
  text = icons.dap_stopped,
  texthl = "DapBreak",
  numhl = "DapBreak",
})

dapview.setup({
  auto_toggle = true,
})

vim.keymap.set("n", "<F1>", dap.step_over, { desc = "[d]ebug step [o]ver" })
vim.keymap.set("n", "<F2>", dap.step_into, { desc = "[d]ebug step [i]nto" })
vim.keymap.set("n", "<F3>", dap.step_out, { desc = "[d]ebug step [o]ut" })
vim.keymap.set("n", "<F4>", dap.step_back, { desc = "[d]ebug step [b]ack" })
vim.keymap.set("n", "<F5>", dap.continue, { desc = "[d]ebug [c]ontinue/start" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[d]ebug [c]ontinue/start" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "[d]ebug step [o]ver" })
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "[d]ebug step [O]ut" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "[d]ebug step [i]nto" })
vim.keymap.set("n", "<leader>db", dap.step_back, { desc = "[d]ebug step [b]ack" })
vim.keymap.set("n", "<leader>tb", dap.toggle_breakpoint, { desc = "[t]oggle [b]reakpoint" })
vim.keymap.set("n", "<leader>tB", dap.clear_breakpoints, { desc = "clear [t]oggled [B]reakpoints" })
vim.keymap.set("n", "<leader>d?", function()
  widgets.hover()
end, { desc = "[d]ebug inspect" })
vim.keymap.set("n", "<leader>dt", function()
  vim.cmd("DapViewToggle")
end, { desc = "[d]ebug [t]oggle ui" })
vim.keymap.set("n", "<leader>dd", function()
  vim.cmd("DapViewToggle")
end, { desc = "[d]ebug [t]oggle ui" })
vim.keymap.set("n", "<leader>d=", function()
  vim.cmd("DapViewClose!")
  vim.cmd("DapViewOpen")
end, { desc = "reset [d]ebug ui" })

require("config.plugins.debug.netcoredbg").setup()
