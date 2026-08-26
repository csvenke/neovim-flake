-- Notification helpers that enforce a consistent title/progress pattern.
local M = {}

---Create a one-shot notifier bound to a title.
---@param title string
---@return fun(msg: string, level?: integer)
function M.with_title(title)
  return function(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = title })
  end
end

---@class NotifyProgress
---@field done fun(msg?: string, level?: integer)
---@field fail fun(msg: string, level?: integer)
---@field update fun(msg: string, level?: integer)

---Show a progress notification and return a handle to finish or update it.
---The progress notification never times out; terminal notifications time out
---after `opts.timeout` (default: 5000).
---@param title string
---@param msg string progress message stem
---@param opts? { timeout?: integer|false }
---@return NotifyProgress
function M.progress(title, msg, opts)
  opts = opts or {}
  local timeout = opts.timeout
  if timeout == nil then
    timeout = 5000
  end

  local notification = vim.notify(msg, vim.log.levels.INFO, {
    title = title,
    timeout = false,
  })

  local function replace(new_msg, level)
    vim.notify(new_msg, level or vim.log.levels.INFO, {
      title = title,
      replace = notification and notification.id,
      timeout = timeout,
    })
  end

  return {
    update = replace,
    done = function(final_msg, level)
      replace(final_msg or (msg .. " DONE"), level)
    end,
    fail = function(err_msg, level)
      replace(err_msg, level or vim.log.levels.ERROR)
    end,
  }
end

return M
