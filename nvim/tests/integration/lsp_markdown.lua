-- luacheck: globals describe it assert

local runner = require("integration_test.lsp_runner")

runner.define({
  describe = "Markdown integration test",
  it = "attaches markdown_oxide client",
  client_name = "markdown_oxide",
  timeout_ms = 30000,
  request_timeout_ms = 2000,
  probes = {
    {
      type = "attach",
      assert = function(client)
        assert.are.equal("markdown_oxide", client.name)
      end,
    },
  },
})
