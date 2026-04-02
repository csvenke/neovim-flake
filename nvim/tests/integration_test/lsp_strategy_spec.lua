local strategy = require("integration_test.lsp_strategy")

describe("integration_test.lsp_strategy", function()
  it("accepts the stable probe types", function()
    local result = strategy.validate({
      describe = "TypeScript integration test",
      it = "runs the stable probes",
      client_name = "ts_ls",
      probes = {
        { type = "attach" },
        { type = "completion", label = "message" },
        { type = "definition", path_suffix = "src/lib.ts" },
        { type = "diagnostic", message_contains = "missing_value" },
      },
    })

    assert.are.equal("ts_ls", result.client_name)
  end)

  it("rejects unsupported probe types", function()
    local ok, err = pcall(function()
      strategy.validate({
        describe = "TypeScript integration test",
        it = "rejects unsupported probes",
        client_name = "ts_ls",
        probes = {
          { type = "hover" },
        },
      })
    end)

    assert.is_false(ok)
    assert.is_truthy(err:find("Unsupported LSP strategy probe type", 1, true))
  end)

  it("requires completion probes to declare a label", function()
    local ok, err = pcall(function()
      strategy.validate({
        describe = "TypeScript integration test",
        it = "requires completion labels",
        client_name = "ts_ls",
        probes = {
          { type = "completion" },
        },
      })
    end)

    assert.is_false(ok)
    assert.is_truthy(err:find("probe #1 label", 1, true))
  end)
end)
