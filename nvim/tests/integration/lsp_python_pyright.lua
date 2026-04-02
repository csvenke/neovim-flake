-- luacheck: globals describe it assert

local runner = require("integration_test.lsp_runner")

runner.define({
  describe = "Python pyright integration test",
  it = "attaches and reports type-check diagnostics",
  client_name = "pyright",
  timeout_ms = 30000,
  probes = {
    {
      type = "attach",
      assert = function(client)
        assert.are.equal("pyright", client.name)
      end,
    },
    {
      type = "diagnostic",
      source = "Pyright",
      message_contains = "missing_value",
      assert = function(diagnostic)
        assert.are.equal("Pyright", diagnostic.source)
        assert.is_truthy((diagnostic.message or ""):find("missing_value", 1, true))
      end,
    },
  },
})
