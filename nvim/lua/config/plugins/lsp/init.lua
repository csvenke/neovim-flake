require("blink.cmp").setup({
  keymap = {
    preset = "default",
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
      sql = { "dadbod", "snippets", "buffer" },
    },
    providers = {
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

require("config.plugins.lsp.roslyn").setup()

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

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map("<leader>th", function()
        local enable = not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
        vim.lsp.inlay_hint.enable(enable)
      end, "[t]oggle inlay [h]ints")
    end

    local icons = require("config.lib.icons")

    vim.diagnostic.config({
      severity_sort = true,
      underline = false,
      float = { border = "rounded", source = "if_many" },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = icons.diagnostic_error .. " ",
          [vim.diagnostic.severity.WARN] = icons.diagnostic_warn .. " ",
          [vim.diagnostic.severity.INFO] = icons.diagnostic_info .. " ",
          [vim.diagnostic.severity.HINT] = icons.diagnostic_hint .. " ",
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
