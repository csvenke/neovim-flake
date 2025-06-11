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
  ];

  # https://github.com/NixNeovim/NixNeovimPlugins
  extraPlugins = with pkgs.vimExtraPlugins; [
    # Themes
    nordic-alexczyl
  ];
in

plugins ++ extraPlugins
