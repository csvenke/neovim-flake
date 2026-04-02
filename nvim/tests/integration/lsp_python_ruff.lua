-- luacheck: globals describe it assert

local runner = require("integration_test.lsp_runner")

runner.define({
  describe = "Python ruff integration test",
  it = "attaches and reports lint diagnostics",
  client_name = "ruff",
  timeout_ms = 30000,
  probes = {
    {
      type = "attach",
      assert = function(client)
        assert.are.equal("ruff", client.name)
      end,
    },
    {
      type = "diagnostic",
      source = "Ruff",
      code = "F401",
      message_contains = "imported but unused",
      assert = function(diagnostic)
        assert.are.equal("Ruff", diagnostic.source)
        assert.are.equal("F401", tostring(diagnostic.code))
      end,
    },
  },
})
