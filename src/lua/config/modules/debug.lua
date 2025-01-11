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

vim.keymap.set("n", "<F1>", dap.continue, { desc = "[d]ebug continue" })
vim.keymap.set("n", "<F2>", dap.step_into, { desc = "[d]ebug step into" })
vim.keymap.set("n", "<F3>", dap.step_over, { desc = "[d]ebug step over" })
vim.keymap.set("n", "<F4>", dap.step_out, { desc = "[d]ebug step out" })
vim.keymap.set("n", "<F5>", dap.step_back, { desc = "[d]ebug step back" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "toggle [d]ebug [b]reakpoint" })
vim.keymap.set("n", "<leader>dB", dap.clear_breakpoints, { desc = "clear [d]ebug [B]reakpoints" })

vim.keymap.set("n", "<space>d?", function()
  dapui.eval(nil, { enter = true })
end, { desc = "[d]ebug inspect" })

vim.keymap.set("n", "<leader>dd", function()
  dapui.toggle({ reset = true })
end, { desc = "toggle [d]ebug ui" })

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
