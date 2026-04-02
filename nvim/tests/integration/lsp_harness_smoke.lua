-- luacheck: globals describe it assert

local bootstrap = require("integration_test.bootstrap")
local lsp = require("integration_test.lsp")

describe("integration test harness smoke", function()
  it("preserves the wrapped neovim boundary", function()
    local workspace_root = bootstrap.workspace_root()
    local open_file = assert(vim.env.INTEGRATION_TEST_OPEN_FILE)

    assert.are.equal("neovim-flake", vim.env.NVIM_APPNAME)
    assert.are.equal(" ", vim.g.mapleader)
    assert.is_nil(vim.o.runtimepath:find(workspace_root .. "/nvim", 1, true))
    assert.are.equal(0, vim.fn.executable("fswatch"))
    assert.are.equal(0, vim.fn.executable("inotifywait"))

    if vim.uv.os_uname().sysname == "Linux" then
      assert.are.equal(1, vim.fn.executable("xclip"))
      assert.are.equal(1, vim.fn.executable("wl-copy"))
    end

    local ok, err = pcall(bootstrap.open_file, "/tmp/outside-workspace")

    assert.is_false(ok)
    assert.is_truthy(err:find("must stay within the workspace root", 1, true))

    local bufnr, path = bootstrap.open_file(open_file)

    assert.are.equal(workspace_root, vim.fn.getcwd())
    assert.are.equal(path, vim.api.nvim_buf_get_name(bufnr))
    assert.is_true(lsp.wait_until("opened buffer", function()
      return vim.api.nvim_buf_is_loaded(bufnr)
    end, { timeout_ms = 1000 }))
  end)
end)
