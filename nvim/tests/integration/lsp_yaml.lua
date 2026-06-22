-- luacheck: globals describe it assert

local runner = require("integration_test.lsp_runner")

runner.define({
  describe = "YAML integration test",
  it = "attaches and reports syntax diagnostics",
  client_name = "yamlls",
  timeout_ms = 30000,
  request_timeout_ms = 2000,
  probes = {
    {
      type = "attach",
      assert = function(client)
        assert.are.equal("yamlls", client.name)
      end,
    },
    {
      type = "diagnostic",
      message_contains = 'Missing closing "quote',
      prepare = function(context)
        vim.api.nvim_buf_set_lines(context.bufnr, 1, 2, false, { 'version: "unclosed' })
      end,
      assert = function(diagnostic)
        assert.is_truthy((diagnostic.message or ""):find('Missing closing "quote', 1, true))
      end,
    },
  },
})
