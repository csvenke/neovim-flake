-- luacheck: globals describe it assert

local bootstrap = require("integration_test.bootstrap")
local runner = require("integration_test.lsp_runner")

runner.define({
  describe = "Nix integration test",
  it = "attaches and resolves local definitions inside a flake workspace",
  client_name = "nixd",
  timeout_ms = 30000,
  request_timeout_ms = 2000,
  probes = {
    {
      type = "attach",
      assert = function(client)
        assert.are.equal("nixd", client.name)
      end,
    },
    {
      type = "definition",
      path_suffix = "default.nix",
      prepare = function(context)
        bootstrap.set_cursor(context.bufnr, "greeting", { occurrence = 2 })
      end,
      assert = function(definition, context)
        local uri = definition.targetUri or definition.uri
        local range = definition.targetSelectionRange or definition.targetRange or definition.range

        assert.is_truthy(uri)
        assert.is_truthy(vim.uri_to_fname(uri):find(context.workspace_root, 1, true))
        assert.are.equal(1, range.start.line)
      end,
    },
  },
})
