{ pkgs }:

let
  plugins = with pkgs.vimPlugins; [
    # Core
    plenary-nvim
    vim-sleuth

    # Direnv
    direnv-vim

    # Treesitter
    nvim-treesitter.withAllGrammars
    nvim-treesitter-context
    nvim-ts-autotag

    # LSP
    SchemaStore-nvim
    fidget-nvim
    lazydev-nvim
    nvim-lspconfig
    omnisharp-extended-lsp-nvim
    nvim-jdtls

    # Debug
    nvim-dap
    nvim-dap-ui
    nvim-dap-virtual-text
    nvim-nio

    # Autocomplete
    friendly-snippets
    blink-cmp-avante
    blink-cmp

    # Formatting
    conform-nvim

    # Fuzzy search
    telescope-nvim
    telescope-fzf-native-nvim
    telescope-ui-select-nvim

    # Git
    diffview-nvim
    gitsigns-nvim

    # Test
    neotest
    neotest-plenary
    neotest-jest

    # Ui
    nui-nvim
    nvim-notify
    noice-nvim
    lualine-nvim
    rest-nvim

    # Keymaps
    which-key-nvim

    # Navigation
    oil-nvim
    harpoon2
    nvim-tree-lua
    smart-splits-nvim
    flash-nvim

    # Startup
    alpha-nvim
    vim-startuptime

    # Icons
    nvim-web-devicons

    # Misc
    mini-nvim
    snacks-nvim

    # LLMs
    render-markdown-nvim
    avante-nvim

    # Database
    vim-dadbod
    vim-dadbod-ui
    vim-dadbod-completion
  ];

  extraPlugins = with pkgs; [
    (vimUtils.buildVimPlugin {
      pname = "nordic";
      version = "2025-06-15";
      src = fetchFromGitHub {
        owner = "AlexvZyl";
        repo = "nordic.nvim";
        rev = "6afe957722fb1b0ec7ca5fbea5a651bcca55f3e1";
        sha256 = "sha256-NY4kjeq01sMTg1PZeVVa2Vle4KpLwWEv4y34cDQ6JMU=";
      };
    })
  ];
in

plugins ++ extraPlugins
