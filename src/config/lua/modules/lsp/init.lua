local function default_on_attach(client, buffer)
  local map = require("util").make_map_buffer(buffer)

  map("gd", vim.lsp.buf.definition, "[g]oto [d]efinition(s)")
  map("gD", vim.lsp.buf.declaration, "[g]oto [D]eclaration")
  map("gi", vim.lsp.buf.implementation, "[g]oto [i]mplementation(s)")
  map("gr", vim.lsp.buf.references, "[g]oto [r]eference(s)")
  map("K", vim.lsp.buf.hover, "Hover documentation")
  map("<leader>D", vim.lsp.buf.type_definition, "type [D]efinition(s)")
  map("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction", { "n", "x" })
  map("<leader>cr", vim.lsp.buf.rename, "[c]ode [r]ename")
  map("<leader>cd", vim.diagnostic.open_float, "[c]ode [d]iagnostic")

  if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
    local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = buffer,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      buffer = buffer,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
      group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
      callback = function(event)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event.buf })
      end,
    })
  end
end

require("fidget").setup({})
require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})
require("neoconf").setup({})
require("blink.cmp").setup({
  keymap = { preset = "default" },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "mono",
  },
  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
  },
  completion = {
    menu = {
      draw = {
        treesitter = true,
        columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind", gap = 1 } },
      },
    },
  },
  providers = {
    lazydev = {
      name = "LazyDev",
      module = "lazydev.integrations.blink",
      score_offset = 100,
    },
  },
})

local lspconfig = require("lspconfig")
local capabilities = require("blink.cmp").get_lsp_capabilities()
local servers = require("modules.lsp.servers")

for server, config in pairs(servers) do
  config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
  config.on_attach = lspconfig.util.add_hook_after(default_on_attach, config.on_attach or function() end)
  lspconfig[server].setup(config)
end

vim.diagnostic.config({
  underline = false,
})
