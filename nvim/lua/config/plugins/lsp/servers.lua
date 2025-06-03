--- @type table<string, vim.lsp.Config>
local servers = {
  nixd = {
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

      ---@diagnostic disable-next-line: undefined-field
      client.config.settings.nixd.nixpkgs.expr = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs {}"
      client:notify("workspace/didChangeConfiguration", {
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
      hostInfo = "neovim",
      preferences = {
        importModuleSpecifierPreference = "relative",
        importModuleSpecifierEnding = "minimal",
      },
    },
  },

  angularls = {},

  omnisharp = {
    settings = {
      FormattingOptions = {
        EnableEditorConfigSupport = true,
        OrganizeImports = false,
      },
      RoslynExtensionsOptions = {
        EnableAnalyzersSupport = true,
      },
    },
    on_attach = function(_, buffer)
      local map = require("config.util").make_map_buffer(buffer)
      local omnisharp = require("omnisharp_extended")

      map("gd", omnisharp.telescope_lsp_definition, "[g]oto [d]efinition (omnisharp)")
      map("gi", omnisharp.telescope_lsp_implementation, "[g]oto [i]mplementation (omnisharp)")
      map("gr", omnisharp.telescope_lsp_references, "[g]oto [r]eferences (omnisharp)")
      map("<leader>D", omnisharp.telescope_lsp_type_definition, "type [D]efinition (omnisharp)")
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

  html = {
    filetypes = { "html", "htmlangular", "templ" },
  },
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

  tailwindcss = {},
}

return servers
