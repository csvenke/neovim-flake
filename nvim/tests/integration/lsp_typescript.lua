-- luacheck: globals describe it assert

local bootstrap = require("integration_test.bootstrap")
local runner = require("integration_test.lsp_runner")

runner.define({
  describe = "TypeScript integration test",
  it = "attaches and serves completion and definition requests",
  client_name = "ts_ls",
  timeout_ms = 30000,
  request_timeout_ms = 2000,
  probes = {
    {
      type = "attach",
      assert = function(client)
        assert.are.equal("ts_ls", client.name)
      end,
    },
    {
      type = "completion",
      label = "message",
      prepare = function(context)
        local completion_line = "greeter.me"
        vim.api.nvim_buf_set_lines(context.bufnr, -1, -1, false, { "", completion_line })
        bootstrap.set_cursor(context.bufnr, completion_line, { col_offset = #completion_line })
      end,
      assert = function(item)
        assert.are.equal("message", item.label)
      end,
    },
    {
      type = "definition",
      path_suffix = "src/lib.ts",
      prepare = function(context)
        bootstrap.set_cursor(context.bufnr, "createGreeter()")
      end,
      assert = function(definition, context)
        local uri = definition.targetUri or definition.uri

        assert.is_truthy(uri)
        assert.is_truthy(vim.uri_to_fname(uri):find(context.workspace_root, 1, true))
      end,
    },
  },
})
