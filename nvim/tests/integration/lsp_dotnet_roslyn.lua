-- luacheck: globals describe it assert

local bootstrap = require("integration_test.bootstrap")
local runner = require("integration_test.lsp_runner")

local sdk_major = assert(vim.env.INTEGRATION_TEST_DOTNET_SDK_MAJOR)

runner.define({
  describe = string.format("Roslyn .NET %s integration test", sdk_major),
  it = "attaches and serves completion and definition requests",
  client_name = "roslyn",
  timeout_ms = 30000,
  request_timeout_ms = 2000,
  probes = {
    {
      type = "attach",
      assert = function(client)
        assert.are.equal("roslyn", client.name)
      end,
    },
    {
      type = "completion",
      label = "Greeter",
      prepare = function(context)
        local completion_line = "var completionTarget = new Gre"
        vim.api.nvim_buf_set_lines(context.bufnr, 1, 1, false, { completion_line })
        bootstrap.set_cursor(context.bufnr, completion_line, { col_offset = #completion_line })
      end,
      assert = function(item)
        assert.are.equal("Greeter", item.label)
      end,
    },
    {
      type = "definition",
      path_suffix = "src/App/Greeter.cs",
      prepare = function(context)
        vim.api.nvim_buf_set_lines(context.bufnr, 1, 2, false, {})
        bootstrap.set_cursor(context.bufnr, "Greeter.Create()")
      end,
      assert = function(definition, context)
        local uri = definition.targetUri or definition.uri

        assert.is_truthy(uri)
        assert.is_truthy(vim.uri_to_fname(uri):find(context.workspace_root, 1, true))
      end,
    },
  },
})
