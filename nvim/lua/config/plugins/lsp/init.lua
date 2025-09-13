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
  keymap = {
    preset = "default",
    ["<Enter>"] = { "select_and_accept", "fallback" },
  },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "mono",
  },
  cmdline = {
    enabled = false,
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    per_filetype = {
      lua = { "lazydev", "lsp", "path", "snippets", "buffer" },
      sql = { "dadbod", "snippets", "buffer" },
      codecompanion = { "codecompanion" },
    },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
      dadbod = {
        name = "Dadbod",
        module = "vim_dadbod_completion.blink",
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

local servers = require("config.plugins.lsp.servers")

for server, config in pairs(servers) do
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
  callback = function(event)
    local telescope = require("telescope.builtin")

    --- @param keys string
    --- @param func string|fun()
    --- @param desc? string
    --- @param mode? string|table
    local function map(keys, func, desc, mode)
      mode = mode or "n"
      desc = desc or ""
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
    end

    map("gd", telescope.lsp_definitions, "[g]oto [d]efinition(s)")
    map("grd", telescope.lsp_definitions, "[g]oto [d]efinition(s)")
    map("grD", vim.lsp.buf.declaration, "[g]oto [D]eclaration")
    map("grt", telescope.lsp_type_definitions, "[g]oto [t]ype definition(s)")
    map("gri", telescope.lsp_implementations, "[g]oto [i]mplementation(s)")
    map("grr", telescope.lsp_references, "[g]oto [r]eference(s)")
    map("grn", vim.lsp.buf.rename, "[r]e[n]ame")
    map("gra", vim.lsp.buf.code_action, "[g]oto code [a]ction", { "n", "x" })
    map("grA", vim.lsp.buf.code_action, "[g]oto code [A]ction (buffer)")
    map("gO", telescope.lsp_document_symbols, "Open document symbols")
    map("gW", telescope.lsp_dynamic_workspace_symbols, "Open workspace symbols")

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client and client.name == "ts_ls" then
      map("grA", "<cmd>LspTypescriptSourceAction<cr>", "[g]oto code [A]ction (buffer)")
    end

    if client and client.name == "omnisharp" then
      local omnisharp = require("omnisharp_extended")

      map("gd", omnisharp.telescope_lsp_definitions, "[g]oto [d]efinitions (omnisharp)")
      map("grd", omnisharp.telescope_lsp_definitions, "[g]oto [d]efinitions (omnisharp)")
      map("grr", omnisharp.telescope_lsp_references, "[g]oto [r]eferences (omnisharp)")
      map("gri", omnisharp.telescope_lsp_implementation, "[g]oto [i]mplementations (omnisharp)")
      map("grt", omnisharp.telescope_lsp_type_definition, "[g]oto [t]ype definitions (omnisharp)")
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
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

    vim.diagnostic.config({
      severity_sort = true,
      underline = false,
      float = { border = "rounded", source = "if_many" },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      },
      virtual_text = {
        severity = {
          min = vim.diagnostic.severity.WARN,
        },
        source = "if_many",
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    })
  end,
})
