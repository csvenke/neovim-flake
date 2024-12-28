local dap = require("dap")
local dapui = require("dapui")
require("nvim-dap-virtual-text").setup({})

dapui.setup({
  icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
  controls = {
    icons = {
      pause = "⏸",
      play = "▶",
      step_into = "⏎",
      step_over = "⏭",
      step_out = "⏮",
      step_back = "b",
      run_last = "▶▶",
      terminate = "⏹",
      disconnect = "⏏",
    },
  },
})

dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

vim.keymap.set("n", "<F1>", dap.continue, { desc = "debug continue" })
vim.keymap.set("n", "<F2>", dap.step_over, { desc = "debug step over" })
vim.keymap.set("n", "<F3>", dap.step_into, { desc = "debug step into" })
vim.keymap.set("n", "<F4>", dap.step_out, { desc = "debug step out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "debug toggle breakpoint" })

-- dotnet
dap.adapters.coreclr = {
  type = "executable",
  command = "netcoredbg",
  args = { "--interpreter=vscode" },
}
dap.configurations.cs = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
      return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
    end,
  },
}
