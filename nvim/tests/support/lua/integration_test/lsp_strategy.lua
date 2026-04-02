local M = {}

local supported_probe_types = {
  attach = true,
  completion = true,
  definition = true,
  diagnostic = true,
}

local function require_string(value, label)
  if type(value) ~= "string" or value == "" then
    error(string.format("Missing LSP strategy %s", label))
  end

  return value
end

local function require_function(value, label)
  if value ~= nil and type(value) ~= "function" then
    error(string.format("LSP strategy %s must be a function", label))
  end

  return value
end

local function require_probes(strategy)
  if type(strategy.probes) ~= "table" or vim.tbl_isempty(strategy.probes) then
    error("Missing LSP strategy probes")
  end

  return strategy.probes
end

local function validate_probe(strategy, probe, index)
  if type(probe) ~= "table" then
    error(string.format("LSP strategy probe #%d must be a table", index))
  end

  local probe_type = require_string(probe.type, string.format("probe #%d type", index))

  if not supported_probe_types[probe_type] then
    error(string.format("Unsupported LSP strategy probe type: %s", probe_type))
  end

  if probe_type == "completion" then
    require_string(probe.label, string.format("probe #%d label", index))
  end

  require_function(probe.prepare, string.format("probe #%d prepare", index))
  require_function(probe.assert, string.format("probe #%d assert", index))

  if probe.client_name ~= nil then
    require_string(probe.client_name, string.format("probe #%d client_name", index))
  elseif probe_type ~= "diagnostic" or strategy.client_name ~= nil then
    require_string(strategy.client_name, "client_name")
  end
end

function M.validate(strategy)
  if type(strategy) ~= "table" then
    error("LSP strategy must be a table")
  end

  require_string(strategy.describe, "describe")
  require_string(strategy.it, "it")

  for index, probe in ipairs(require_probes(strategy)) do
    validate_probe(strategy, probe, index)
  end

  return strategy
end

M.supported_probe_types = vim.tbl_keys(supported_probe_types)

return M
