local neotest = require("neotest")

neotest.setup({
  adapters = {
    require("neotest-plenary"),
    require("neotest-jest")({
      jestCommand = "npm test --",
      env = { CI = true },
      cwd = function()
        return vim.fn.getcwd()
      end,
    }),
    require("neotest-vitest"),
    require("neotest-dotnet"),
  },
})

vim.keymap.set("n", "<leader>tt", function()
  neotest.run.run()
end, { desc = "[t]est nearest" })

vim.keymap.set("n", "<leader>tf", function()
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "[t]est current [f]ile" })

vim.keymap.set("n", "<leader>ts", function()
  neotest.summary.toggle()
end, { desc = "[t]est toggle [s]ummary" })
