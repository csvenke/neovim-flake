--- @type table<string, vim.lsp.Config>
local servers = {
  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/nixd.lua
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

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/lua_ls.lua
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
        },
      },
    },
  },

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/bashls.lua
  bashls = {},

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/hls.lua
  hls = {},

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/hls.lua
  jdtls = {},

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/rust_analyzer.lua
  rust_analyzer = {},

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/ts_ls.lua
  ts_ls = {
    init_options = {
      hostInfo = "neovim",
      preferences = {
        importModuleSpecifierPreference = "relative",
        importModuleSpecifierEnding = "minimal",
      },
    },
  },

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/angularls.lua
  angularls = {
    on_init = function(client)
      -- Defer to ts_ls
      client.server_capabilities.referencesProvider = false
    end,
  },

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/marksman.lua
  marksman = {},

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/pyright.lua
  pyright = {
    enabled = true,
  },

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/ruff.lua
  ruff = {
    on_init = function(client)
      -- Defer to pyright
      client.server_capabilities.hoverProvider = false
      client.server_capabilities.renameProvider = false
    end,
  },

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/yamlls.lua
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

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/html.lua
  html = {
    filetypes = { "html", "htmlangular", "templ" },
  },

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/cssls.lua
  cssls = {},

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/css_variables.lua
  css_variables = {},

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/eslint.lua
  eslint = {},

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/jsonls.lua
  jsonls = {
    settings = {
      json = {
        format = { enable = true },
        validate = { enable = true },
        schemas = require("schemastore").json.schemas(),
      },
    },
  },

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/taplo.lua
  taplo = {},

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/tailwindcss.lua
  tailwindcss = {},

  --- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/gopls.lua
  gopls = {
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
        gofumpt = true,
      },
    },
  },
}

return servers
