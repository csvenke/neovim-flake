---@diagnostic disable: duplicate-set-field
describe("config.runtime.popup", function()
  local popup
  local original_getcwd
  local original_jobstart

  local function cleanup_popups()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local config = vim.api.nvim_win_get_config(win)
      if config.relative ~= "" then
        pcall(vim.api.nvim_win_close, win, true)
      end
    end

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.b[buf].popup_id ~= nil then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    end
  end

  before_each(function()
    package.loaded["config.runtime.popup"] = nil
    original_getcwd = vim.fn.getcwd
    original_jobstart = vim.fn.jobstart
    popup = require("config.runtime.popup")
  end)

  after_each(function()
    vim.fn.getcwd = original_getcwd
    vim.fn.jobstart = original_jobstart
    cleanup_popups()
  end)

  it("reuses the same buffer for the same popup id and cwd", function()
    vim.fn.getcwd = function()
      return "/tmp/project"
    end
    vim.fn.jobstart = function()
      return 1
    end

    local first_buf, first_win = popup.toggle({ id = "terminal" })
    local second_buf, second_win = popup.toggle({ id = "terminal" })
    local third_buf, third_win = popup.toggle({ id = "terminal" })

    assert.are.equal(first_buf, second_buf)
    assert.are.equal(first_buf, third_buf)
    assert.are.equal(first_win, second_win)
    assert.is_false(vim.api.nvim_win_is_valid(second_win))
    assert.is_true(vim.api.nvim_win_is_valid(third_win))
  end)

  it("uses cwd as part of popup identity", function()
    local cwd = "/tmp/project-a"

    vim.fn.getcwd = function()
      return cwd
    end
    vim.fn.jobstart = function()
      return 1
    end

    local first_buf = popup.toggle({ id = "terminal" })
    cwd = "/tmp/project-b"
    local second_buf = popup.toggle({ id = "terminal" })

    assert.are_not.equal(first_buf, second_buf)
  end)
end)
