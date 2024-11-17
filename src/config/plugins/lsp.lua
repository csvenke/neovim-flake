require("fidget").setup({})
require("neodev").setup({})
require("neoconf").setup({})

local function make_map_buffer(buffer)
  return function(keys, func, desc, mode)
    mode = mode or "n"
    vim.keymap.set(mode, keys, func, { buffer = buffer, desc = desc })
  end
end

local function default_on_attach(client, buffer)
  local map = make_map_buffer(buffer)
  local telescope = require("telescope.builtin")

  map("gd", telescope.lsp_definitions, "[g]oto [d]efinition(s)")
  map("gD", vim.lsp.buf.declaration, "[g]oto [D]eclaration")
  map("gi", telescope.lsp_implementations, "[g]oto [i]mplementation(s)")
  map("gr", telescope.lsp_references, "[g]oto [r]eference(s)")
  map("K", vim.lsp.buf.hover, "Hover documentation")
  map("<leader>D", telescope.lsp_type_definitions, "type [D]efinition(s)")
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
        options = {
          ["flake-parts"] = {
            expr = '(builtins.getFlake ("git+file://" + toString ./.)).currentSystem.options',
          },
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
    enable_editorconfig_support = true,
    enable_ms_build_load_projects_on_demand = false,
    enable_roslyn_analyzers = true,
    organize_imports_on_format = false,
    enable_import_completion = true,
    sdk_include_prereleases = true,
    analyze_open_documents_only = false,
    on_attach = function(_, buffer)
      local map = make_map_buffer(buffer)
      local omnisharp = require("omnisharp_extended")

      map("gd", omnisharp.lsp_definition, "[g]oto [d]efinition")
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

local capabilities = vim.tbl_deep_extend(
  "force",
  vim.lsp.protocol.make_client_capabilities(),
  require("cmp_nvim_lsp").default_capabilities()
)

local lspconfig = require("lspconfig")

for server, config in pairs(servers) do
  config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
  config.on_attach = lspconfig.util.add_hook_after(default_on_attach, config.on_attach or function() end)
  lspconfig[server].setup(config)
end

vim.diagnostic.config({
  underline = false,
})
