---@diagnostic disable: duplicate-set-field
describe("config.runtime.workspace", function()
  local Workspace
  local Path
  local original_buf_get_name
  local original_buf_is_loaded
  local original_set_current_dir
  local original_cmd
  local original_get_clients
  local original_getcwd
  local original_wait
  local original_diagnostic_reset
  local original_fnameescape
  local original_is_file
  local original_bufremove

  before_each(function()
    package.loaded["config.runtime.workspace"] = nil
    original_buf_get_name = vim.api.nvim_buf_get_name
    original_buf_is_loaded = vim.api.nvim_buf_is_loaded
    original_set_current_dir = vim.api.nvim_set_current_dir
    original_cmd = vim.cmd
    original_get_clients = vim.lsp.get_clients
    original_getcwd = vim.fn.getcwd
    original_wait = vim.wait
    original_diagnostic_reset = vim.diagnostic.reset
    original_fnameescape = vim.fn.fnameescape

    Path = require("config.lib.path")
    original_is_file = Path.is_file
    original_bufremove = package.loaded["mini.bufremove"]
    package.loaded["mini.bufremove"] = {
      delete = function() end,
    }

    Workspace = require("config.runtime.workspace")
  end)

  after_each(function()
    vim.api.nvim_buf_get_name = original_buf_get_name
    vim.api.nvim_buf_is_loaded = original_buf_is_loaded
    vim.api.nvim_set_current_dir = original_set_current_dir
    vim.cmd = original_cmd
    vim.lsp.get_clients = original_get_clients
    vim.fn.getcwd = original_getcwd
    vim.wait = original_wait
    vim.diagnostic.reset = original_diagnostic_reset
    vim.fn.fnameescape = original_fnameescape
    Path.is_file = original_is_file
    package.loaded["mini.bufremove"] = original_bufremove
  end)

  it("keeps the matching relative file open when changing workspaces", function()
    local commands = {}
    local deleted_buffers = {}
    local switched_to
    local diagnostics_reset = false

    package.loaded["mini.bufremove"] = {
      delete = function(buffer, force)
        table.insert(deleted_buffers, { buffer, force })
      end,
    }
    Path.is_file = function(path)
      return path == "/new-worktree/lua/config.lua"
    end
    vim.fn.getcwd = function()
      return "/old-worktree"
    end
    vim.fn.fnameescape = function(path)
      return path
    end
    vim.api.nvim_buf_get_name = function()
      return "/old-worktree/lua/config.lua"
    end
    vim.api.nvim_buf_is_loaded = function(buffer)
      return buffer == 11
    end
    vim.api.nvim_set_current_dir = function(path)
      switched_to = path
    end
    vim.cmd = setmetatable({
      edit = function(path)
        table.insert(commands, "edit " .. path)
      end,
    }, {
      __call = function(_, command)
        table.insert(commands, command)
      end,
    })
    vim.lsp.get_clients = function()
      return {
        {
          attached_buffers = { [11] = true },
          stop = function() end,
          is_stopped = function()
            return true
          end,
        },
      }
    end
    vim.wait = function(_, predicate)
      return predicate()
    end
    vim.diagnostic.reset = function()
      diagnostics_reset = true
    end

    Workspace.change_current_directory("/new-worktree")

    assert.are.equal("/new-worktree", switched_to)
    assert.is_true(diagnostics_reset)
    assert.are.same({ { 11, true } }, deleted_buffers)
    assert.are.same({ "silent! wa", "edit lua/config.lua", "delmarks!", "clearjumps" }, commands)
  end)

  it("falls back to editing the workspace root when the previous file is missing", function()
    local commands = {}

    Path.is_file = function()
      return false
    end
    vim.fn.getcwd = function()
      return "/old-worktree"
    end
    vim.fn.fnameescape = function(path)
      return path
    end
    vim.api.nvim_buf_get_name = function()
      return "/old-worktree/lua/missing.lua"
    end
    vim.api.nvim_buf_is_loaded = function()
      return false
    end
    vim.api.nvim_set_current_dir = function() end
    vim.cmd = setmetatable({
      edit = function(path)
        table.insert(commands, "edit " .. path)
      end,
    }, {
      __call = function(_, command)
        table.insert(commands, command)
      end,
    })
    vim.lsp.get_clients = function()
      return {}
    end
    vim.wait = function(_, predicate)
      return predicate()
    end
    vim.diagnostic.reset = function() end

    Workspace.change_current_directory("/new-worktree")

    assert.is_truthy(vim.tbl_contains(commands, "edit ."))
  end)
end)
