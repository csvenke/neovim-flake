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
    nvim-treesitter-textobjects
    nvim-treesitter-refactor
    nvim-treesitter-context
    nvim-ts-autotag

    # LSP
    SchemaStore-nvim
    fidget-nvim
    lazydev-nvim
    neoconf-nvim
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
    blink-cmp

    # Formatting
    conform-nvim

    # Fuzzy search
    telescope-nvim
    telescope-fzf-native-nvim
    telescope-ui-select-nvim

    # Git
    lazygit-nvim
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
    nvim-navic
    barbecue-nvim

    # Keymaps
    which-key-nvim

    # Navigation
    oil-nvim
    harpoon2
    neo-tree-nvim
    smart-splits-nvim

    # Startup
    alpha-nvim
    vim-startuptime

    # Icons
    nvim-web-devicons

    # Misc
    mini-nvim
  ];

  # https://github.com/NixNeovim/NixNeovimPlugins
  extraPlugins = with pkgs.vimExtraPlugins; [
    # Themes
    nordic-alexczyl

    # LLMs
    gp-nvim
  ];
in

plugins ++ extraPlugins
