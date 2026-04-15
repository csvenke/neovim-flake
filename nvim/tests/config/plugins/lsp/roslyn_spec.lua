describe("config.plugins.lsp.roslyn", function()
  local original_roslyn
  local original_lsp_config
  local original_create_augroup
  local original_create_autocmd
  local original_get_clients
  local original_buf_is_loaded
  local original_diagnostic_refresh

  before_each(function()
    package.loaded["config.plugins.lsp.roslyn"] = nil

    original_roslyn = package.loaded["roslyn"]
    original_lsp_config = vim.lsp.config
    original_create_augroup = vim.api.nvim_create_augroup
    original_create_autocmd = vim.api.nvim_create_autocmd
    original_get_clients = vim.lsp.get_clients
    original_buf_is_loaded = vim.api.nvim_buf_is_loaded
    original_diagnostic_refresh = vim.lsp.diagnostic._refresh
  end)

  after_each(function()
    package.loaded["roslyn"] = original_roslyn
    vim.lsp.config = original_lsp_config
    vim.api.nvim_create_augroup = original_create_augroup
    vim.api.nvim_create_autocmd = original_create_autocmd
    vim.lsp.get_clients = original_get_clients
    vim.api.nvim_buf_is_loaded = original_buf_is_loaded
    vim.lsp.diagnostic._refresh = original_diagnostic_refresh
  end)

  local function setup()
    local captured_opts
    local captured_config
    local captured_autocmd
    local captured_group

    package.loaded["roslyn"] = {
      setup = function(opts)
        captured_opts = opts
      end,
    }

    vim.lsp.config = function(name, config)
      captured_config = { name = name, config = config }
    end

    vim.api.nvim_create_augroup = function(name, opts)
      captured_group = { name = name, opts = opts }
      return 17
    end

    vim.api.nvim_create_autocmd = function(events, opts)
      captured_autocmd = { events = events, opts = opts }
      return 23
    end

    require("config.plugins.lsp.roslyn").setup()

    return captured_opts, captured_config, captured_group, captured_autocmd
  end

  it("uses the current minimal roslyn setup contract", function()
    local opts, config, group, autocmd = setup()

    assert.are.equal("roslyn", opts.filewatching)
    assert.is_true(opts.silent)
    assert.are.same({ name = "roslyn", config = { workspace_required = true } }, config)
    assert.are.same({ name = "user-lsp-roslyn-hooks", opts = { clear = true } }, group)
    assert.are.same({ "CursorHold", "FocusGained" }, autocmd.events)
    assert.are.equal(17, autocmd.opts.group)
    assert.are.same({ "*.cs", "*.razor" }, autocmd.opts.pattern)
  end)

  it("refreshes diagnostics for loaded roslyn buffers on idle or refocus", function()
    local refreshes = {}
    local _, _, _, autocmd = setup()

    vim.lsp.get_clients = function(opts)
      assert.are.same({ bufnr = 9, name = "roslyn" }, opts)

      return {
        {
          id = 41,
          attached_buffers = { [9] = true, [12] = true },
        },
      }
    end

    vim.api.nvim_buf_is_loaded = function(bufnr)
      return bufnr ~= 12
    end

    vim.lsp.diagnostic._refresh = function(bufnr, client_id)
      table.insert(refreshes, { bufnr = bufnr, client_id = client_id })
    end

    autocmd.opts.callback({ buf = 9 })

    assert.are.same({
      {
        bufnr = 9,
        client_id = 41,
      },
    }, refreshes)
  end)
end)
