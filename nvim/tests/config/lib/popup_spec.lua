local mock = require("luassert.mock")
local Popup = require("config.lib.popup")

describe("config.lib.popup", function()
  local vim_api
  local vim_fn
  local vim_b
  local vim_o

  before_each(function()
    vim_api = {
      nvim_list_bufs = mock.new(function()
        return {}
      end),
      nvim_buf_is_loaded = mock.new(function()
        return true
      end),
      nvim_open_win = mock.new(function()
        return 101
      end),
      nvim_win_close = mock.new(function() end),
      nvim_create_buf = mock.new(function()
        return 201
      end),
      nvim_buf_call = mock.new(function(buf, cb)
        cb()
      end),
      nvim_set_option_value = mock.new(function() end),
      nvim_create_augroup = mock.new(function()
        return 1
      end),
      nvim_create_autocmd = mock.new(function() end),
      nvim_del_augroup_by_id = mock.new(function() end),
      nvim_win_is_valid = mock.new(function()
        return true
      end),
      nvim_win_set_config = mock.new(function() end),
      nvim_buf_delete = mock.new(function() end),
    }

    vim_fn = {
      getcwd = mock.new(function()
        return "/test/cwd"
      end),
      bufwinid = mock.new(function()
        return -1
      end),
      jobstart = mock.new(function()
        return 1
      end),
    }

    vim_b = setmetatable({}, {
      __index = function()
        return {}
      end,
    })

    vim_o = {
      columns = 100,
      lines = 30,
      shell = "bash",
    }

    vim.api = vim_api
    vim.fn = vim_fn
    vim.b = vim_b
    vim.o = vim_o
  end)

  after_each(function()
    mock.revert(vim_api)
    mock.revert(vim_fn)
  end)

  describe("toggle", function()
    it("creates a new popup window when called for the first time", function()
      -- Given
      local opts = { id = "test-popup", cmd = "ls" }

      -- When
      local buf, win = Popup.toggle(opts)

      -- Then
      assert.spy(vim_api.nvim_create_buf).was_called()
      assert.spy(vim_api.nvim_open_win).was_called()
      assert.are.equal(201, buf)
      assert.are.equal(101, win)
    end)

    it("closes the existing popup window when called again", function()
      -- Given
      local opts = { id = "test-popup", cmd = "ls" }
      local existing_buf = 201

      vim.api.nvim_list_bufs = mock.new(function()
        return { existing_buf }
      end)
      vim_b[existing_buf] = {
        popup_id = opts.id,
        popup_cwd = "/test/cwd",
      }
      vim.fn.bufwinid = mock.new(function(buf)
        if buf == existing_buf then
          return 101
        end
        return -1
      end)

      -- When
      local buf, win = Popup.toggle(opts)

      -- Then
      assert.spy(vim_api.nvim_win_close).was_called_with(101, true)
      assert.are.equal(existing_buf, buf)
      assert.are.equal(101, win)
    end)

    -- it("opens a new window if buffer exists but window is closed", function()
    --   -- Given
    --   local opts = { id = "test-popup", cmd = "ls" }
    --   local existing_buf = 201
    --
    --   vim.api.nvim_list_bufs = mock.new(function()
    --     return { existing_buf }
    --   end)
    --   vim_b[existing_buf] = {
    --     popup_id = opts.id,
    --     popup_cwd = "/test/cwd",
    --   }
    --   -- bufwinid returns -1, simulating a closed window
    --
    --   -- When
    --   local buf, win = Popup.toggle(opts)
    --
    --   -- Then
    --   assert.spy(vim_api.nvim_open_win).was_called_with(existing_buf, true, assert.is_table())
    --   assert.are.equal(existing_buf, buf)
    --   assert.are.equal(101, win)
    -- end)
  end)
end)
