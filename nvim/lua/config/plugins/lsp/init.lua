local blink = require("blink.cmp")

local icons = require("config.lib.icons")
local servers = require("config.plugins.lsp.servers")

local lsp_attach_group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true })
local lsp_highlight_group = vim.api.nvim_create_augroup("user-lsp-highlight", { clear = false })
local lsp_detach_group = vim.api.nvim_create_augroup("user-lsp-detach", { clear = false })

blink.setup({
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "mono",
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
        columns = {
          { "label" },
          { "kind_icon" },
          { "kind" },
        },
      },
    },
  },
})

require("config.plugins.lsp.roslyn").setup()

for server, config in pairs(servers) do
  config.capabilities = blink.get_lsp_capabilities(config.capabilities)
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

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
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_attach_group,
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
      vim.api.nvim_clear_autocmds({ group = lsp_highlight_group, buffer = event.buf })

      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = lsp_highlight_group,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = lsp_highlight_group,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_clear_autocmds({ group = lsp_detach_group, buffer = event.buf })

      vim.api.nvim_create_autocmd("LspDetach", {
        buffer = event.buf,
        group = lsp_detach_group,
        callback = function(detach_event)
          local clients = vim.lsp.get_clients({
            bufnr = detach_event.buf,
            method = vim.lsp.protocol.Methods.textDocument_documentHighlight,
          })
          if #clients > 0 then
            return
          end

          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = lsp_highlight_group, buffer = detach_event.buf })
          vim.api.nvim_clear_autocmds({ group = lsp_detach_group, buffer = detach_event.buf })
        end,
      })
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map("<leader>th", function()
        local enable = not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
        vim.lsp.inlay_hint.enable(enable, { bufnr = event.buf })
      end, "[t]oggle inlay [h]ints")
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens, event.buf) then
      map("<leader>tl", function()
        local enable = not vim.lsp.codelens.is_enabled({ bufnr = event.buf })
        vim.lsp.codelens.enable(enable, { bufnr = event.buf })
      end, "[t]oggle code [l]enses")
    end
  end,
})
