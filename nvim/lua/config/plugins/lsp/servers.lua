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
          globals = { "require", "vim" },
          disable = {
            "missing-fields",
            "duplicate-doc-field",
          },
        },
      },
    },
  },

  bashls = {},

  hls = {},

  jdtls = {},

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

  angularls = {
    on_init = function(client)
      -- Defer to ts_ls
      client.server_capabilities.referencesProvider = false
    end,
  },

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
  },

  marksman = {},

  -- Python
  pyright = {
    enabled = true,
  },

  ruff = {
    on_init = function(client)
      -- Defer to pyright
      client.server_capabilities.hoverProvider = false
      client.server_capabilities.renameProvider = false
    end,
  },

  yamlls = {
    settings = {
      yaml = {
        format = { enable = true },
        validate = { enable = true },
        schemas = require("schemastore").yaml.schemas(),
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
    settings = {
      json = {
        format = { enable = true },
        validate = { enable = true },
        schemas = require("schemastore").json.schemas(),
      },
    },
  },

  taplo = {},

  tailwindcss = {},
}

return servers
