local bootstrap = require("integration_test.bootstrap")

describe("integration_test.bootstrap", function()
  local original_isdirectory
  local original_workspace_root
  local original_buf_get_lines
  local original_win_set_cursor
  local cursor_position

  before_each(function()
    original_isdirectory = vim.fn.isdirectory
    original_workspace_root = vim.env.INTEGRATION_TEST_WORKSPACE_ROOT
    original_buf_get_lines = vim.api.nvim_buf_get_lines
    original_win_set_cursor = vim.api.nvim_win_set_cursor

    vim.fn.isdirectory = function()
      return 1
    end
    vim.env.INTEGRATION_TEST_WORKSPACE_ROOT = "/tmp/integration-workspace"
    cursor_position = nil
  end)

  after_each(function()
    vim.fn.isdirectory = original_isdirectory
    vim.env.INTEGRATION_TEST_WORKSPACE_ROOT = original_workspace_root
    vim.api.nvim_buf_get_lines = original_buf_get_lines
    vim.api.nvim_win_set_cursor = original_win_set_cursor
  end)

  it("builds workspace-relative absolute paths", function()
    assert.are.equal("/tmp/integration-workspace/src/App/Program.cs", bootstrap.absolute_path("src/App/Program.cs"))
  end)

  it("rejects absolute paths outside the copied workspace", function()
    local ok, err = pcall(function()
      return bootstrap.absolute_path("/tmp/outside-workspace")
    end)

    assert.is_false(ok)
    assert.is_truthy(err:find("must stay within the workspace root", 1, true))
  end)

  it("rejects relative paths that escape the copied workspace", function()
    local ok, err = pcall(function()
      return bootstrap.absolute_path("../outside-workspace")
    end)

    assert.is_false(ok)
    assert.is_truthy(err:find("must stay within the workspace root", 1, true))
  end)

  it("fails when the workspace root is missing", function()
    vim.env.INTEGRATION_TEST_WORKSPACE_ROOT = nil

    local ok, err = pcall(bootstrap.workspace_root)

    assert.is_false(ok)
    assert.is_truthy(err:find("INTEGRATION_TEST_WORKSPACE_ROOT", 1, true))
  end)

  it("finds a cursor position from buffer text", function()
    local line = "var completionTarget = new Gre"

    vim.api.nvim_buf_get_lines = function()
      return {
        "alpha",
        line,
      }
    end

    local position = bootstrap.cursor_position(7, line, { col_offset = #line })

    assert.are.same({ 2, #line }, position)
  end)

  it("sets the current window cursor from buffer text", function()
    vim.api.nvim_buf_get_lines = function()
      return {
        "Console.WriteLine(Greeter.Create().Message());",
      }
    end
    vim.api.nvim_win_set_cursor = function(_, position)
      cursor_position = position
    end

    local position = bootstrap.set_cursor(3, "Greeter.Create()")

    assert.are.same({ 1, 18 }, position)
    assert.are.same({ 1, 18 }, cursor_position)
  end)
end)
