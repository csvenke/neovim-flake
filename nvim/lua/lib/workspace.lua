local M = {}

local plugins = {}
local enabled_before = {}
local skip_checks = {}

function M.register(name, is_enabled_fn, toggle_fn)
  plugins[name] = {
    is_enabled = is_enabled_fn,
    toggle = toggle_fn,
  }
end

function M.register_skip(name, check_fn)
  skip_checks[name] = check_fn
end

function M.should_skip(win_id)
  for _, check_fn in pairs(skip_checks) do
    if check_fn(win_id) then
      return true
    end
  end
  return false
end

function M.enter()
  enabled_before = {}
  for name, plugin in pairs(plugins) do
    if plugin.is_enabled() then
      enabled_before[name] = true
      plugin.toggle()
    end
  end
  return enabled_before
end

function M.exit()
  for name, _ in pairs(enabled_before) do
    local plugin = plugins[name]
    if plugin then
      vim.defer_fn(plugin.toggle, 50)
    end
  end
  enabled_before = {}
end

return M
