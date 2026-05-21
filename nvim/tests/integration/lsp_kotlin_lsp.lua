-- luacheck: globals describe it assert

local runner = require("integration_test.lsp_runner")

runner.define({
  describe = "Kotlin LSP integration test",
  it = "attaches to a Kotlin file in a Gradle project",
  client_name = "kotlin_lsp",
  timeout_ms = 60000,
  request_timeout_ms = 2000,
  probes = {
    {
      type = "attach",
      assert = function(client)
        assert.are.equal("kotlin_lsp", client.name)
      end,
    },
  },
})
