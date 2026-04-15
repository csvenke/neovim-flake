local runner = require("integration_test.lsp_runner")

describe("integration_test.lsp_runner", function()
  local original_open_file
  local original_workspace_root
  local original_attach
  local original_completion
  local original_definition
  local original_diagnostic
  local original_diagnostic_absent
  local original_open_file_env

  before_each(function()
    original_open_file = require("integration_test.bootstrap").open_file
    original_workspace_root = require("integration_test.bootstrap").workspace_root
    original_attach = require("integration_test.lsp").assert_client_attached
    original_completion = require("integration_test.lsp").assert_completion_contains
    original_definition = require("integration_test.lsp").assert_definition_matches
    original_diagnostic = require("integration_test.lsp").assert_diagnostic_matches
    original_diagnostic_absent = require("integration_test.lsp").assert_diagnostic_absent
    original_open_file_env = vim.env.INTEGRATION_TEST_OPEN_FILE
  end)

  after_each(function()
    require("integration_test.bootstrap").open_file = original_open_file
    require("integration_test.bootstrap").workspace_root = original_workspace_root
    require("integration_test.lsp").assert_client_attached = original_attach
    require("integration_test.lsp").assert_completion_contains = original_completion
    require("integration_test.lsp").assert_definition_matches = original_definition
    require("integration_test.lsp").assert_diagnostic_matches = original_diagnostic
    require("integration_test.lsp").assert_diagnostic_absent = original_diagnostic_absent
    vim.env.INTEGRATION_TEST_OPEN_FILE = original_open_file_env
  end)

  it("runs stable probes with shared context and hooks", function()
    local bootstrap = require("integration_test.bootstrap")
    local lsp = require("integration_test.lsp")
    local calls = {}

    vim.env.INTEGRATION_TEST_OPEN_FILE = "src/index.ts"

    bootstrap.open_file = function(relative_path)
      table.insert(calls, { stage = "open_file", relative_path = relative_path })
      return 7, "/tmp/workspace/src/index.ts"
    end
    bootstrap.workspace_root = function()
      return "/tmp/workspace"
    end
    lsp.assert_client_attached = function(opts)
      table.insert(calls, { stage = "attach", opts = opts })
      return { name = opts.client_name }
    end
    lsp.assert_completion_contains = function(opts)
      table.insert(calls, { stage = "completion", opts = opts })
      return { label = opts.label }
    end
    lsp.assert_definition_matches = function(opts)
      table.insert(calls, { stage = "definition", opts = opts })
      return { uri = "file:///tmp/workspace/src/lib.ts" }
    end
    lsp.assert_diagnostic_matches = function(opts)
      table.insert(calls, { stage = "diagnostic", opts = opts })
      return { message = opts.message_contains }
    end
    lsp.assert_diagnostic_absent = function(opts)
      table.insert(calls, { stage = "diagnostic_absent", opts = opts })
      return true
    end

    local context = runner.run({
      describe = "TypeScript integration test",
      it = "runs the shared runner",
      client_name = "ts_ls",
      timeout_ms = 30000,
      request_timeout_ms = 2000,
      probes = {
        {
          type = "attach",
          prepare = function(inner_context)
            table.insert(calls, { stage = "prepare_attach", bufnr = inner_context.bufnr })
          end,
          assert = function(result, inner_context)
            table.insert(calls, {
              stage = "assert_attach",
              client = result.name,
              workspace_root = inner_context.workspace_root,
            })
          end,
        },
        {
          type = "completion",
          label = "message",
        },
        {
          type = "definition",
          path_suffix = "src/lib.ts",
        },
        {
          type = "diagnostic",
          message_contains = "missing_value",
        },
        {
          type = "diagnostic_absent",
          message_contains = "missing_value",
        },
      },
    })

    assert.are.equal(7, context.bufnr)
    assert.are.equal("ts_ls", context.client.name)
    assert.are.equal("message", context.results[2].label)
    assert.are.equal("missing_value", context.results[4].message)
    assert.is_true(context.results[5])

    assert.are.same({ stage = "open_file", relative_path = "src/index.ts" }, calls[1])
    assert.are.same({ stage = "prepare_attach", bufnr = 7 }, calls[2])
    assert.are.equal("attach", calls[3].stage)
    assert.are.equal("completion", calls[5].stage)
    assert.are.equal("definition", calls[6].stage)
    assert.are.equal("diagnostic", calls[7].stage)
    assert.are.equal("diagnostic_absent", calls[8].stage)
    assert.are.same({ stage = "assert_attach", client = "ts_ls", workspace_root = "/tmp/workspace" }, calls[4])
    assert.are.equal("ts_ls", calls[3].opts.client_name)
    assert.are.equal(30000, calls[3].opts.timeout_ms)
    assert.are.equal(2000, calls[5].opts.request_timeout_ms)
    assert.are.equal("src/lib.ts", calls[6].opts.path_suffix)
    assert.are.equal("missing_value", calls[7].opts.message_contains)
    assert.are.equal("missing_value", calls[8].opts.message_contains)
  end)
end)
