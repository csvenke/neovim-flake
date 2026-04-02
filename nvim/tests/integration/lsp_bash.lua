-- luacheck: globals describe it assert

local bootstrap = require("integration_test.bootstrap")
local runner = require("integration_test.lsp_runner")

runner.define({
  describe = "Bash integration test",
  it = "attaches and resolves function definitions",
  client_name = "bashls",
  timeout_ms = 30000,
  request_timeout_ms = 2000,
  probes = {
    {
      type = "attach",
      assert = function(client)
        assert.are.equal("bashls", client.name)
      end,
    },
    {
      type = "definition",
      path_suffix = "script.sh",
      prepare = function(context)
        bootstrap.set_cursor(context.bufnr, "greet", { occurrence = 2 })
      end,
      assert = function(definition, context)
        local uri = definition.targetUri or definition.uri
        local range = definition.targetSelectionRange or definition.targetRange or definition.range

        assert.is_truthy(uri)
        assert.is_truthy(vim.uri_to_fname(uri):find(context.workspace_root, 1, true))
        assert.are.equal(5, range.start.line)
      end,
    },
  },
})
