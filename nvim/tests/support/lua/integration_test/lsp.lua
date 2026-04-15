local M = {
  default_timeout_ms = 10000,
  default_interval_ms = 100,
  default_request_timeout_ms = 250,
}

local methods = vim.lsp.protocol.Methods
  or {
    textDocument_completion = "textDocument/completion",
    textDocument_definition = "textDocument/definition",
  }

local function ends_with(value, suffix)
  return suffix == nil or value:sub(-#suffix) == suffix
end

local function normalize_client_id(client_id)
  return tonumber(client_id) or client_id
end

local function get_client(bufnr, client_name)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = client_name })
  return clients[1]
end

local function get_matching_response(opts)
  local responses = vim.lsp.buf_request_sync(
    opts.bufnr,
    opts.method,
    opts.params,
    opts.request_timeout_ms or M.default_request_timeout_ms
  )

  if type(responses) ~= "table" then
    return nil
  end

  for client_id, response in pairs(responses) do
    local client = vim.lsp.get_client_by_id(normalize_client_id(client_id))

    if not opts.client_name or (client and client.name == opts.client_name) then
      if response and response.err then
        error(
          string.format("LSP %s request failed: %s", opts.method, response.err.message or vim.inspect(response.err))
        )
      end

      return {
        client = client,
        result = response and response.result or nil,
      }
    end
  end

  return nil
end

local function completion_items(result)
  if type(result) ~= "table" then
    return {}
  end

  if vim.islist(result) then
    return result
  end

  return result.items or {}
end

local function definition_locations(result)
  if type(result) ~= "table" then
    return {}
  end

  if result.uri or result.targetUri then
    return { result }
  end

  return result
end

local function diagnostic_matches(diagnostic, opts)
  local message = diagnostic.message or ""

  if opts.severity and diagnostic.severity ~= opts.severity then
    return false
  end

  if opts.source and diagnostic.source ~= opts.source then
    return false
  end

  if opts.code and tostring(diagnostic.code) ~= tostring(opts.code) then
    return false
  end

  if opts.message and message ~= opts.message then
    return false
  end

  if opts.message_contains and not message:find(opts.message_contains, 1, true) then
    return false
  end

  if opts.message_pattern and not message:match(opts.message_pattern) then
    return false
  end

  return true
end

function M.wait_until(description, predicate, opts)
  opts = opts or {}

  local timeout_ms = opts.timeout_ms or M.default_timeout_ms
  local interval_ms = opts.interval_ms or M.default_interval_ms
  local resolved
  local last_error

  local ok = vim.wait(timeout_ms, function()
    local success, result = pcall(predicate)

    if not success then
      last_error = result
      return false
    end

    if result then
      resolved = result
      return true
    end

    return false
  end, interval_ms)

  if not ok then
    local message = string.format("Timed out waiting for %s after %dms", description, timeout_ms)

    if last_error then
      message = message .. string.format(": %s", last_error)
    end

    error(message)
  end

  return resolved
end

function M.assert_client_attached(opts)
  local bufnr = opts.bufnr or 0
  local client_name = opts.client_name

  if type(client_name) ~= "string" or client_name == "" then
    error("Missing LSP client_name")
  end

  return M.wait_until(string.format("LSP client %s to attach", client_name), function()
    return get_client(bufnr, client_name)
  end, opts)
end

function M.request_sync(opts)
  local response = get_matching_response(opts)

  if not response or response.result == nil then
    error(string.format("No %s response from LSP client %s", opts.method, opts.client_name or "<any>"))
  end

  return response.result, response.client
end

function M.assert_completion_contains(opts)
  local bufnr = opts.bufnr or 0
  local client = M.assert_client_attached(opts)

  if type(opts.label) ~= "string" or opts.label == "" then
    error("Missing completion label")
  end

  return M.wait_until(string.format("completion item %s", opts.label), function()
    local response = get_matching_response({
      bufnr = bufnr,
      client_name = opts.client_name,
      method = methods.textDocument_completion,
      params = opts.params or vim.lsp.util.make_position_params(0, client.offset_encoding),
      request_timeout_ms = opts.request_timeout_ms,
    })

    for _, item in ipairs(completion_items(response and response.result)) do
      if item.label == opts.label then
        return item
      end
    end

    return false
  end, opts)
end

function M.assert_definition_matches(opts)
  local bufnr = opts.bufnr or 0
  local client = M.assert_client_attached(opts)

  return M.wait_until(string.format("definition %s", opts.path_suffix or opts.uri_suffix or "response"), function()
    local response = get_matching_response({
      bufnr = bufnr,
      client_name = opts.client_name,
      method = methods.textDocument_definition,
      params = opts.params or vim.lsp.util.make_position_params(0, client.offset_encoding),
      request_timeout_ms = opts.request_timeout_ms,
    })

    for _, location in ipairs(definition_locations(response and response.result)) do
      local uri = location.targetUri or location.uri

      if uri then
        local path = vim.uri_to_fname(uri)

        if ends_with(uri, opts.uri_suffix) and ends_with(path, opts.path_suffix) then
          return location
        end
      end
    end

    return false
  end, opts)
end

function M.assert_diagnostic_matches(opts)
  local bufnr = opts.bufnr or 0

  if opts.client_name then
    M.assert_client_attached(opts)
  end

  local description = opts.message or opts.message_contains or opts.source or "response"

  return M.wait_until(string.format("diagnostic %s", description), function()
    if opts.poll then
      opts.poll()
    end

    for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
      if diagnostic_matches(diagnostic, opts) then
        return diagnostic
      end
    end

    return false
  end, opts)
end

function M.assert_diagnostic_absent(opts)
  local bufnr = opts.bufnr or 0

  if opts.client_name then
    M.assert_client_attached(opts)
  end

  local description = opts.message or opts.message_contains or opts.source or "response"

  M.wait_until(string.format("diagnostic %s to clear", description), function()
    if opts.poll then
      opts.poll()
    end

    for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
      if diagnostic_matches(diagnostic, opts) then
        return false
      end
    end

    return true
  end, opts)

  return true
end

return M
