-- luacheck: globals describe it assert

local bootstrap = require("integration_test.bootstrap")
local runner = require("integration_test.lsp_runner")

runner.define({
  describe = "Lua integration test",
  it = "attaches and serves definition requests and diagnostics",
  client_name = "lua_ls",
  timeout_ms = 30000,
  request_timeout_ms = 2000,
  probes = {
    {
      type = "attach",
      assert = function(client)
        assert.are.equal("lua_ls", client.name)
      end,
    },
    {
      type = "definition",
      path_suffix = "main.lua",
      prepare = function(context)
        bootstrap.set_cursor(context.bufnr, "message()")
      end,
      assert = function(definition, context)
        local uri = definition.targetUri or definition.uri
        local range = definition.targetSelectionRange or definition.targetRange or definition.range

        assert.is_truthy(uri)
        assert.is_truthy(vim.uri_to_fname(uri):find(context.workspace_root, 1, true))
        assert.are.equal(3, range.start.line)
      end,
    },
    {
      type = "diagnostic",
      message_contains = "missing_value",
      prepare = function(context)
        vim.api.nvim_buf_set_lines(context.bufnr, 9, 10, false, { "print(missing_value) " })
        vim.api.nvim_buf_set_lines(context.bufnr, 9, 10, false, { "print(missing_value)" })
      end,
      assert = function(diagnostic)
        assert.is_truthy((diagnostic.message or ""):find("missing_value", 1, true))
      end,
    },
  },
})
