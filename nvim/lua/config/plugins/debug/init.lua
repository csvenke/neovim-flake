local dap = require("dap")
local dapui = require("dapui")
require("nvim-dap-virtual-text").setup({})

local highlight_augroup = vim.api.nvim_create_augroup("DapHighlights", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = highlight_augroup,
  callback = function()
    vim.cmd([[
      highlight DapStop guifg=#E7C173 gui=bold
      highlight DapBreak guifg=#B74E58 gui=bold
    ]])
  end,
})

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreak", numhl = "DapBreak" })
vim.fn.sign_define("DapBreakpointCondition", { text = "⊜", texthl = "DapBreak", numhl = "DapBreak" })
vim.fn.sign_define("DapBreakpointRejected", { text = "⊘", texthl = "DapBreak", numhl = "DapBreak" })
vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapBreak", numhl = "DapBreak" })
vim.fn.sign_define("DapStopped", { text = "|>", texthl = "DapStop", numhl = "DapStop" })

dapui.setup({
  layouts = {
    {
      size = 80,
      position = "right",
      elements = {
        { id = "watches", size = 0.25 },
        { id = "scopes", size = 0.25 },
        { id = "stacks", size = 0.25 },
        { id = "breakpoints", size = 0.25 },
      },
    },
  },
})

dap.listeners.before.attach.dapui_config = dapui.open
dap.listeners.before.launch.dapui_config = dapui.open
dap.listeners.before.event_terminated.dapui_config = dapui.close
dap.listeners.before.event_exited.dapui_config = dapui.close

vim.keymap.set("n", "<F1>", dap.step_over, { desc = "[d]ebug step [o]ver" })
vim.keymap.set("n", "<F2>", dap.step_into, { desc = "[d]ebug step [i]nto" })
vim.keymap.set("n", "<F5>", dap.continue, { desc = "[d]ebug [c]ontinue/start" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[d]ebug [c]ontinue" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "[d]ebug step [o]ver" })
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "[d]ebug step [O]ut" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "[d]ebug step [i]nto" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "toggle [d]ebug [b]reakpoint" })
vim.keymap.set("n", "<leader>dB", dap.clear_breakpoints, { desc = "clear [d]ebug [B]reakpoints" })
vim.keymap.set("n", "<leader>d?", function()
  dapui.eval(nil, { enter = true })
end, { desc = "[d]ebug inspect" })
vim.keymap.set("n", "<leader>dt", function()
  dapui.toggle({ reset = true })
end, { desc = "[d]ebug [t]oggle ui" })
vim.keymap.set("n", "<leader>dd", function()
  dapui.toggle({ reset = true })
end, { desc = "[d]ebug [t]oggle ui" })
vim.keymap.set("n", "<leader>d=", function()
  dapui.open({ reset = true })
end, { desc = "reset [d]ebug ui" })

require("config.plugins.debug.netcoredbg").setup()
