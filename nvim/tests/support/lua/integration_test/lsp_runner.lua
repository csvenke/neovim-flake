-- luacheck: globals describe it

local bootstrap = require("integration_test.bootstrap")
local lsp = require("integration_test.lsp")
local strategy_schema = require("integration_test.lsp_strategy")

local M = {}

local function maybe_assign(target, key, value)
  if value ~= nil then
    target[key] = value
  end
end

local function probe_options(context, probe)
  local strategy = context.strategy
  local opts = {
    bufnr = context.bufnr,
    client_name = probe.client_name or strategy.client_name,
  }

  maybe_assign(opts, "timeout_ms", probe.timeout_ms or strategy.timeout_ms)
  maybe_assign(opts, "interval_ms", probe.interval_ms or strategy.interval_ms)
  maybe_assign(opts, "request_timeout_ms", probe.request_timeout_ms or strategy.request_timeout_ms)
  maybe_assign(opts, "params", probe.params)
  maybe_assign(opts, "label", probe.label)
  maybe_assign(opts, "uri_suffix", probe.uri_suffix)
  maybe_assign(opts, "path_suffix", probe.path_suffix)
  maybe_assign(opts, "severity", probe.severity)
  maybe_assign(opts, "source", probe.source)
  maybe_assign(opts, "code", probe.code)
  maybe_assign(opts, "message", probe.message)
  maybe_assign(opts, "message_contains", probe.message_contains)
  maybe_assign(opts, "message_pattern", probe.message_pattern)
  maybe_assign(opts, "poll", probe.poll and function()
    return probe.poll(context)
  end)

  return opts
end

local probe_runners = {
  attach = function(context, probe)
    return lsp.assert_client_attached(probe_options(context, probe))
  end,
  completion = function(context, probe)
    return lsp.assert_completion_contains(probe_options(context, probe))
  end,
  definition = function(context, probe)
    return lsp.assert_definition_matches(probe_options(context, probe))
  end,
  diagnostic = function(context, probe)
    return lsp.assert_diagnostic_matches(probe_options(context, probe))
  end,
  diagnostic_absent = function(context, probe)
    return lsp.assert_diagnostic_absent(probe_options(context, probe))
  end,
}

local function assert_opened_path(opened_path, workspace_root)
  if not opened_path:find(workspace_root, 1, true) then
    error(string.format("Integration-test path must stay within the workspace root: %s", opened_path))
  end
end

local function execute(strategy)
  local bufnr, opened_path = bootstrap.open_file(assert(vim.env.INTEGRATION_TEST_OPEN_FILE))
  local workspace_root = bootstrap.workspace_root()

  assert_opened_path(opened_path, workspace_root)

  local context = {
    strategy = strategy,
    bufnr = bufnr,
    opened_path = opened_path,
    workspace_root = workspace_root,
    results = {},
  }

  for index, probe in ipairs(strategy.probes) do
    if probe.prepare then
      probe.prepare(context)
    end

    local result = probe_runners[probe.type](context, probe)
    context.results[index] = result
    context.last_result = result

    if probe.type == "attach" then
      context.client = result
    end

    if probe.assert then
      probe.assert(result, context)
    end
  end

  return context
end

function M.run(strategy)
  return execute(strategy_schema.validate(strategy))
end

function M.define(strategy)
  strategy = strategy_schema.validate(strategy)

  describe(strategy.describe, function()
    it(strategy.it, function()
      execute(strategy)
    end)
  end)
end

return M
