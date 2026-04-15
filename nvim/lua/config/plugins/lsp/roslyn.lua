local M = {}

local diagnostic_method = vim.lsp.protocol.Methods.textDocument_diagnostic or "textDocument/diagnostic"

---@param bufnr number
---@param client vim.lsp.Client
local function refresh_buffer_diagnostics(bufnr, client)
  if vim.lsp.diagnostic and vim.lsp.diagnostic._refresh then
    vim.lsp.diagnostic._refresh(bufnr, client.id)
    return
  end

  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  client:request(diagnostic_method, params, nil, bufnr)
end

---@param bufnr number
local function refresh_attached_diagnostics(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "roslyn" })
  for _, client in ipairs(clients) do
    for attached_buf in pairs(client.attached_buffers or {}) do
      if vim.api.nvim_buf_is_loaded(attached_buf) then
        refresh_buffer_diagnostics(attached_buf, client)
      end
    end
  end
end

function M.setup()
  require("roslyn").setup({
    filewatching = "roslyn",
    silent = true,
  })

  vim.lsp.config("roslyn", {
    workspace_required = true,
  })

  local group = vim.api.nvim_create_augroup("user-lsp-roslyn-hooks", { clear = true })

  vim.api.nvim_create_autocmd({ "CursorHold", "FocusGained" }, {
    group = group,
    pattern = { "*.cs", "*.razor" },
    callback = function(args)
      refresh_attached_diagnostics(args.buf)
    end,
  })
end

return M
