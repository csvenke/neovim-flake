-- luacheck: globals describe it assert

local bootstrap = require("integration_test.bootstrap")
local runner = require("integration_test.lsp_runner")

runner.define({
  describe = "Rust integration test",
  it = "attaches and resolves crate definitions",
  client_name = "rust_analyzer",
  timeout_ms = 30000,
  request_timeout_ms = 2000,
  probes = {
    {
      type = "attach",
      assert = function(client)
        assert.are.equal("rust_analyzer", client.name)
      end,
    },
    {
      type = "definition",
      path_suffix = "src/lib.rs",
      prepare = function(context)
        bootstrap.set_cursor(context.bufnr, "create_greeter()")
      end,
      assert = function(definition, context)
        local uri = definition.targetUri or definition.uri

        assert.is_truthy(uri)
        assert.is_truthy(vim.uri_to_fname(uri):find(context.workspace_root, 1, true))
      end,
    },
  },
})
