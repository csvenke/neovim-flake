-- luacheck: globals describe it assert

local bootstrap = require("integration_test.bootstrap")
local runner = require("integration_test.lsp_runner")

local sdk_major = assert(vim.env.INTEGRATION_TEST_DOTNET_SDK_MAJOR)

runner.define({
  describe = string.format("Roslyn .NET %s integration test", sdk_major),
  it = "attaches and clears stale Helper diagnostics after external file creation",
  client_name = "roslyn",
  timeout_ms = 60000,
  request_timeout_ms = 5000,
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
    {
      type = "diagnostic",
      message_contains = "Helper",
      prepare = function(context)
        local missing_line = "Console.WriteLine(Helper.Message());"
        vim.api.nvim_buf_set_lines(context.bufnr, -1, -1, false, { missing_line })
        bootstrap.set_cursor(context.bufnr, missing_line)
        vim.cmd.write()
      end,
      assert = function(diagnostic)
        assert.is_truthy((diagnostic.message or ""):find("Helper", 1, true))
      end,
    },
    {
      type = "diagnostic_absent",
      message_contains = "Helper",
      timeout_ms = 20000,
      prepare = function(context)
        local helper_path = vim.fs.joinpath(context.workspace_root, "src", "App", "Helper.cs")

        vim.fn.writefile({
          "public static class Helper",
          "{",
          '    public static string Message() => "Hello from Helper";',
          "}",
        }, helper_path)

        bootstrap.set_cursor(context.bufnr, "Helper.Message()")
      end,
      poll = function(context)
        vim.api.nvim_exec_autocmds("FocusGained", { buffer = context.bufnr, modeline = false })
        vim.api.nvim_exec_autocmds("CursorHold", { buffer = context.bufnr, modeline = false })
      end,
    },
    {
      type = "definition",
      path_suffix = "src/App/Helper.cs",
      prepare = function(context)
        bootstrap.set_cursor(context.bufnr, "Helper.Message()")
      end,
      assert = function(definition, context)
        local uri = definition.targetUri or definition.uri

        assert.is_truthy(uri)
        assert.is_truthy(vim.uri_to_fname(uri):find(context.workspace_root, 1, true))
      end,
    },
  },
})
