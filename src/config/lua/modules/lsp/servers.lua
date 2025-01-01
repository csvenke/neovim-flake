--- @type table<string, lspconfig.Config>
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
    on_attach = function(client)
      local no_flake = vim.fn.findfile("flake.nix", vim.fn.getcwd()) == ""
      if no_flake then
        return
      end

      client.config.settings.nixd.nixpkgs.expr = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs {}"
      client.notify("workspace/didChangeConfiguration", {
        settings = client.config.settings,
      })
    end,
  },

  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
        },
        diagnostics = {
          disable = { "missing-fields" },
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
        require("util").make_code_action("source.organizeImports.ts"),
        { desc = "[c]ode [o]rganize imports" }
      )
      vim.keymap.set(
        "n",
        "<leader>cR",
        require("util").make_code_action("source.removeUnused.ts"),
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

  angularls = {},

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
      local map = require("util").make_map_buffer(buffer)
      local omnisharp = require("omnisharp_extended")

      map("gd", omnisharp.telescope_lsp_definition, "[g]oto [d]efinition (omnisharp)")
      map("gi", omnisharp.telescope_lsp_implementation, "[g]oto [i]mplementation (omnisharp)")
      map("gr", omnisharp.telescope_lsp_references, "[g]oto [r]eferences (omnisharp)")
      map("<leader>D", omnisharp.telescope_lsp_type_definition, "type [D]efinition (omnisharp)")

      vim.diagnostic.config({
        virtual_text = false,
      })
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

return servers
