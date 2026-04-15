local harness = require("integration_test.lsp")

describe("integration_test.lsp", function()
  local original_wait
  local original_get_clients
  local original_get_client_by_id
  local original_buf_request_sync
  local original_make_position_params
  local original_uri_to_fname
  local original_diagnostic_get

  before_each(function()
    original_wait = vim.wait
    original_get_clients = vim.lsp.get_clients
    original_get_client_by_id = vim.lsp.get_client_by_id
    original_buf_request_sync = vim.lsp.buf_request_sync
    original_make_position_params = vim.lsp.util.make_position_params
    original_uri_to_fname = vim.uri_to_fname
    original_diagnostic_get = vim.diagnostic.get
  end)

  after_each(function()
    vim.wait = original_wait
    vim.lsp.get_clients = original_get_clients
    vim.lsp.get_client_by_id = original_get_client_by_id
    vim.lsp.buf_request_sync = original_buf_request_sync
    vim.lsp.util.make_position_params = original_make_position_params
    vim.uri_to_fname = original_uri_to_fname
    vim.diagnostic.get = original_diagnostic_get
  end)

  it("returns the first truthy value from wait_until", function()
    local attempts = 0

    vim.wait = function(_, predicate)
      for _ = 1, 3 do
        if predicate() then
          return true
        end
      end

      return false
    end

    local result = harness.wait_until("attach", function()
      attempts = attempts + 1

      if attempts == 2 then
        return "ready"
      end

      return false
    end, { timeout_ms = 25, interval_ms = 5 })

    assert.are.equal("ready", result)
  end)

  it("raises a bounded timeout error when waiting fails", function()
    vim.wait = function(_, predicate)
      predicate()
      return false
    end

    local ok, err = pcall(function()
      harness.wait_until("client attach", function()
        return false
      end, { timeout_ms = 25, interval_ms = 5 })
    end)

    assert.is_false(ok)
    assert.is_truthy(err:find("Timed out waiting for client attach after 25ms", 1, true))
  end)

  it("returns matching client request results", function()
    vim.lsp.buf_request_sync = function(_, _, _, timeout_ms)
      assert.are.equal(50, timeout_ms)

      return {
        [1] = { result = { label = "ignore" } },
        [2] = { result = { label = "keep" } },
      }
    end
    vim.lsp.get_client_by_id = function(client_id)
      return { id = client_id, name = client_id == 2 and "roslyn" or "lua_ls" }
    end

    local result, client = harness.request_sync({
      bufnr = 3,
      client_name = "roslyn",
      method = "textDocument/completion",
      params = {},
      request_timeout_ms = 50,
    })

    assert.are.same({ label = "keep" }, result)
    assert.are.equal("roslyn", client.name)
  end)

  it("polls until completion contains the expected label", function()
    local requests = 0

    vim.wait = function(_, predicate)
      for _ = 1, 3 do
        if predicate() then
          return true
        end
      end

      return false
    end
    vim.lsp.get_clients = function()
      return {
        { id = 2, name = "roslyn", offset_encoding = "utf-16" },
      }
    end
    vim.lsp.get_client_by_id = function(client_id)
      return { id = client_id, name = "roslyn" }
    end
    vim.lsp.util.make_position_params = function(_, offset_encoding)
      assert.are.equal("utf-16", offset_encoding)
      return { position = { line = 0, character = 0 } }
    end
    vim.lsp.buf_request_sync = function()
      requests = requests + 1

      if requests == 1 then
        return {
          [2] = { result = { items = {} } },
        }
      end

      return {
        [2] = { result = { items = { { label = "Greeter" } } } },
      }
    end

    local item = harness.assert_completion_contains({
      bufnr = 7,
      client_name = "roslyn",
      label = "Greeter",
      timeout_ms = 30,
      request_timeout_ms = 10,
    })

    assert.are.equal("Greeter", item.label)
  end)

  it("matches definitions by file suffix", function()
    vim.wait = function(_, predicate)
      return predicate()
    end
    vim.lsp.get_clients = function()
      return {
        { id = 2, name = "roslyn", offset_encoding = "utf-16" },
      }
    end
    vim.lsp.get_client_by_id = function(client_id)
      return { id = client_id, name = "roslyn" }
    end
    vim.lsp.util.make_position_params = function()
      return { position = { line = 0, character = 0 } }
    end
    vim.lsp.buf_request_sync = function()
      return {
        [2] = {
          result = {
            { uri = "file:///tmp/src/Program.cs" },
            { uri = "file:///tmp/src/Greeter.cs" },
          },
        },
      }
    end
    vim.uri_to_fname = function(uri)
      return uri:gsub("^file://", "")
    end

    local location = harness.assert_definition_matches({
      bufnr = 9,
      client_name = "roslyn",
      path_suffix = "Greeter.cs",
      timeout_ms = 10,
      request_timeout_ms = 10,
    })

    assert.are.equal("file:///tmp/src/Greeter.cs", location.uri)
  end)

  it("polls until diagnostics match the expected fields", function()
    local attempts = 0

    vim.wait = function(_, predicate)
      for _ = 1, 3 do
        if predicate() then
          return true
        end
      end

      return false
    end
    vim.lsp.get_clients = function()
      return {
        { id = 7, name = "ruff" },
      }
    end
    vim.diagnostic.get = function(bufnr)
      attempts = attempts + 1

      assert.are.equal(4, bufnr)

      if attempts == 1 then
        return {
          { message = "ignore", source = "Pyright", severity = vim.diagnostic.severity.WARN },
        }
      end

      return {
        {
          message = "Line too long (99 > 88)",
          source = "Ruff",
          code = "E501",
          severity = vim.diagnostic.severity.WARN,
        },
      }
    end

    local diagnostic = harness.assert_diagnostic_matches({
      bufnr = 4,
      client_name = "ruff",
      source = "Ruff",
      code = "E501",
      message_contains = "Line too long",
      severity = vim.diagnostic.severity.WARN,
      timeout_ms = 30,
    })

    assert.are.equal("Ruff", diagnostic.source)
    assert.are.equal("E501", diagnostic.code)
  end)

  it("waits until matching diagnostics clear", function()
    local attempts = 0
    local polls = 0

    vim.wait = function(_, predicate)
      for _ = 1, 3 do
        if predicate() then
          return true
        end
      end

      return false
    end
    vim.lsp.get_clients = function()
      return {
        { id = 9, name = "roslyn" },
      }
    end
    vim.diagnostic.get = function(bufnr)
      attempts = attempts + 1

      assert.are.equal(5, bufnr)

      if attempts == 1 then
        return {
          { message = "The name 'Helper' does not exist", source = "Roslyn" },
        }
      end

      return {}
    end

    local cleared = harness.assert_diagnostic_absent({
      bufnr = 5,
      client_name = "roslyn",
      source = "Roslyn",
      message_contains = "Helper",
      timeout_ms = 30,
      poll = function()
        polls = polls + 1
      end,
    })

    assert.is_true(cleared)
    assert.are.equal(2, polls)
  end)
end)
