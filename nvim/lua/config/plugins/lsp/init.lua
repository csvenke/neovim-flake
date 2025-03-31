require("fidget").setup({})
require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
  integrations = {
    lspconfig = true,
    cmp = false,
  },
})
require("blink.cmp").setup({
  keymap = { preset = "default" },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "mono",
  },
  cmdline = {
    enabled = false,
  },
  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
    },
  },
  completion = {
    menu = {
      draw = {
        treesitter = { "lsp" },
        columns = { { "label", "kind_icon", "kind", gap = 1 } },
      },
    },
  },
})

local lspconfig = require("lspconfig")
local capabilities = require("blink.cmp").get_lsp_capabilities()
local servers = require("config.plugins.lsp.servers")

for server, config in pairs(servers) do
  config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
  lspconfig[server].setup(config)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
  callback = function(event)
    local buffer = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local map = require("config.util").make_map_buffer(buffer)

    map("gd", vim.lsp.buf.definition, "[g]oto [d]efinition(s)")
    map("gD", vim.lsp.buf.declaration, "[g]oto [D]eclaration")
    map("gi", vim.lsp.buf.implementation, "[g]oto [i]mplementation(s)")
    map("gr", vim.lsp.buf.references, "[g]oto [r]eference(s)")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("<leader>D", vim.lsp.buf.type_definition, "type [D]efinition(s)")
    map("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction", { "n", "x" })
    map("<leader>cr", vim.lsp.buf.rename, "[c]ode [r]ename")
    map("<leader>cd", vim.diagnostic.open_float, "[c]ode [d]iagnostic")

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
        end,
      })
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      map("<leader>ch", function()
        local toggle = not vim.lsp.inlay_hint.is_enabled({ bufnr = buffer })
        vim.lsp.inlay_hint.enable(toggle)
      end, "[c]ode [h]int")
    end

    vim.diagnostic.config({
      underline = false,
      virtual_text = {
        severity = {
          min = vim.diagnostic.severity.WARN,
        },
      },
    })
  end,
})
