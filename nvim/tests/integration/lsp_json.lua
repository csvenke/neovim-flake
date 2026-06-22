-- luacheck: globals describe it assert

local runner = require("integration_test.lsp_runner")

runner.define({
  describe = "JSON integration test",
  it = "attaches and reports syntax diagnostics",
  client_name = "jsonls",
  timeout_ms = 30000,
  request_timeout_ms = 2000,
  probes = {
    {
      type = "attach",
      assert = function(client)
        assert.are.equal("jsonls", client.name)
      end,
    },
    {
      type = "diagnostic",
      message_contains = "Property keys",
      prepare = function(context)
        vim.api.nvim_buf_set_lines(context.bufnr, 1, 2, false, { '  name: "json-lsp-integration"' })
      end,
      assert = function(diagnostic)
        assert.is_truthy((diagnostic.message or ""):find("Property keys", 1, true))
      end,
    },
  },
})
