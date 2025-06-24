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
    --- @param func fun()
    --- @param desc? string
    --- @param mode? string|table
    local function map(keys, func, desc, mode)
      mode = mode or "n"
      desc = desc or ""
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
    end

    map("gd", telescope.lsp_definitions, "[g]oto [d]efinition(s)")
    map("gD", telescope.lsp_type_definitions, "type [D]efinition(s)")
    map("gi", telescope.lsp_implementations, "[g]oto [i]mplementation(s)")
    map("gr", telescope.lsp_references, "[g]oto [r]eference(s)")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("<leader>ss", telescope.lsp_document_symbols, "[s]earch [s]ymbols")
    map("<leader>sS", telescope.lsp_workspace_symbols, "[s]earch [S]ymbols (workspace)")
    map("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction", { "n", "x" })
    map("<leader>cr", vim.lsp.buf.rename, "[c]ode [r]ename")
    map("<leader>cd", vim.diagnostic.open_float, "[c]ode [d]iagnostic")

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client and client.name == "ts_ls" then
      vim.keymap.set("n", "<leader>cA", "<cmd>LspTypescriptSourceAction<cr>", { desc = "[c]ode [A]ction" })
    end

    if client and client.name == "omnisharp" then
      local omnisharp = require("omnisharp_extended")

      map("gd", omnisharp.telescope_lsp_definition, "[g]oto [d]efinition (omnisharp)")
      map("gi", omnisharp.telescope_lsp_implementation, "[g]oto [i]mplementation (omnisharp)")
      map("gr", omnisharp.telescope_lsp_references, "[g]oto [r]eferences (omnisharp)")
      map("<leader>D", omnisharp.telescope_lsp_type_definition, "type [D]efinition (omnisharp)")
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      map("<leader>ch", function()
        local toggle = not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
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
