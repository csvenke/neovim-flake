-- luacheck: globals describe it assert

local bootstrap = require("integration_test.bootstrap")
local runner = require("integration_test.lsp_runner")

runner.define({
  describe = "Go integration test",
  it = "attaches and serves completion requests",
  client_name = "gopls",
  timeout_ms = 30000,
  request_timeout_ms = 2000,
  probes = {
    {
      type = "attach",
      assert = function(client)
        assert.are.equal("gopls", client.name)
      end,
    },
    {
      type = "completion",
      label = "Message",
      prepare = function(context)
        local line_count = vim.api.nvim_buf_line_count(context.bufnr)
        local completion_line = "    fmt.Println(greeter.Mes)"
        vim.api.nvim_buf_set_lines(context.bufnr, line_count - 1, line_count - 1, false, { "", completion_line })
        bootstrap.set_cursor(context.bufnr, "greeter.Mes", { col_offset = #"greeter.Mes" })
      end,
      assert = function(item)
        assert.are.equal("Message", item.label)
      end,
    },
  },
})
