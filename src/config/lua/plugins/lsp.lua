local function make_map_buffer(buffer)
  return function(keys, func, desc, mode)
    mode = mode or "n"
    vim.keymap.set(mode, keys, func, { buffer = buffer, desc = desc })
  end
end

local function default_on_attach(client, buffer)
  local map = make_map_buffer(buffer)

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

local function makeCodeAction(name)
  return function()
    vim.lsp.buf.code_action({
      apply = true,
      context = {
        only = { name },
        diagnostics = {},
      },
    })
  end
end

---@diagnostic disable: missing-fields
---@type lspconfig.options
local servers = {
  nixd = {
    cmd = { "nixd" },
    settings = {
      nixd = {
        nixpkgs = {
          expr = "import <nixpkgs> { }",
        },
        formatting = {
          command = { "nixfmt" },
        },
      },
    },
  },

  bashls = {},

  hls = {},

  jdtls = {
    cmd = { "jdtls" },
  },

  rust_analyzer = {},

  ts_ls = {
    init_options = {
      preferences = {
        importModuleSpecifierPreference = "relative",
        importModuleSpecifierEnding = "minimal",
      },
    },
    root_dir = require("lspconfig").util.root_pattern("package.json"),
    single_file_support = false,
    on_attach = function()
      vim.keymap.set(
        "n",
        "<leader>co",
        makeCodeAction("source.organizeImports.ts"),
        { desc = "[c]ode [o]rganize imports" }
      )
      vim.keymap.set(
        "n",
        "<leader>cR",
        makeCodeAction("source.removeUnused.ts"),
        { desc = "[c]ode [R]emove unused imports" }
      )
    end,
  },

  denols = {
    root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
    on_attach = function()
      vim.g.markdown_fenced_languages = {
        "ts=typescript",
      }
    end,
  },

  angularls = {
    cmd = { "angular-language-server", "--stdio", "--tsProbeLocations", "", "--ngProbeLocations", "" },
    on_new_config = function(new_config)
      new_config.cmd = { "angular-language-server", "--stdio", "--tsProbeLocations", "", "--ngProbeLocations", "" }
    end,
  },

  lua_ls = {
    settings = {
      Lua = {
        library = {
          vim.env.VIMRUNTIME,
        },
        completion = {
          callSnippet = "Replace",
        },
      },
    },
  },

  omnisharp = {
    cmd = { "OmniSharp" },
    settings = {
      FormattingOptions = {
        EnableEditorConfigSupport = true,
        OrganizeImports = false,
      },
      RoslynExtensionsOptions = {
        EnableAnalyzersSupport = true,
        EnableImportCompletion = false,
        AnalyzeOpenDocumentsOnly = false,
      },
      Sdk = {
        IncludePrereleases = true,
      },
    },
    on_attach = function(_, buffer)
      local map = make_map_buffer(buffer)
      local omnisharp = require("omnisharp_extended")

      map("gd", omnisharp.telescope_lsp_definition, "[g]oto [d]efinition")
      map("gi", omnisharp.telescope_lsp_implementation, "[g]oto [i]mplementation")
      map("gr", omnisharp.telescope_lsp_references, "[g]oto [r]eferences")
      map("<leader>D", omnisharp.telescope_lsp_type_definition, "type [D]efinition")
    end,
  },

  marksman = {},

  pyright = {
    enabled = true,
  },

  ruff = {},

  yamlls = {
    on_attach = function(client)
      client.server_capabilities.documentFormattingProvider = true
    end,
    on_new_config = function(new_config)
      new_config.settings.yaml.schemas = new_config.settings.yaml.schemas or {}
      vim.list_extend(new_config.settings.yaml.schemas, require("schemastore").yaml.schemas())
    end,
    capabilities = {
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true,
        },
      },
    },
    settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = {
        keyOrdering = false,
        format = {
          enable = true,
        },
        validate = true,
        schemaStore = {
          enable = false,
          url = "",
        },
      },
    },
  },

  html = {},
  cssls = {},
  css_variables = {},
  eslint = {},
  jsonls = {
    on_new_config = function(new_config)
      new_config.settings.json.schemas = new_config.settings.json.schemas or {}
      vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
    end,
    settings = {
      json = {
        format = {
          enable = true,
        },
        validate = { enable = true },
      },
    },
  },

  taplo = {},

  gleam = {},

  tailwindcss = {
    root_dir = require("lspconfig").util.root_pattern(
      "tailwind.config.js",
      "tailwind.config.cjs",
      "tailwind.config.mjs",
      "tailwind.config.ts"
    ),
  },
}

require("fidget").setup({})
require("neodev").setup({})
require("neoconf").setup({})
require("blink.cmp").setup({
  keymap = { preset = "default" },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "mono",
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  signature = { enabled = false },
})

local lspconfig = require("lspconfig")
local capabilities = require("blink.cmp").get_lsp_capabilities()

for server, config in pairs(servers) do
  config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
  config.on_attach = lspconfig.util.add_hook_after(default_on_attach, config.on_attach or function() end)
  lspconfig[server].setup(config)
end

vim.diagnostic.config({
  underline = false,
})
