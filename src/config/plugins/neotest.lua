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
  },
})

vim.keymap.set("n", "<leader>tt", function()
  neotest.run.run()
end, { desc = "[t]est nearest" })

vim.keymap.set("n", "<leader>tf", function()
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "[t]est current [f]ile" })
