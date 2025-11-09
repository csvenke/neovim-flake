{ pkgs }:

let
  kulala-http-grammar = pkgs.tree-sitter.buildGrammar rec {
    language = "kulala_http";
    version = "c328aeb219c4b77106917dd2698c90ea9657281b";
    src = pkgs.fetchFromGitHub {
      owner = "mistweaverco";
      repo = "kulala.nvim";
      rev = version;
      sha256 = "12vxb24lqw5vpwfy57jd55461wmr6cyg2nq4mh1wk5jvhidlc1im";
    };
    location = "lua/tree-sitter";
    generate = false;
  };

  plugins = with pkgs.vimPlugins; [
    plenary-nvim
    guess-indent-nvim

    # Treesitter
    (nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars ++ [ kulala-http-grammar ]))
    nvim-treesitter-context
    nvim-ts-autotag

    # LSP
    SchemaStore-nvim
    fidget-nvim
    lazydev-nvim
    nvim-lspconfig
    ## LSP: Dotnet
    omnisharp-extended-lsp-nvim
    ## LSP: Java
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
    diffview-nvim
    gitsigns-nvim

    # Test
    vim-test

    # Ui
    nui-nvim
    nvim-notify
    noice-nvim
    lualine-nvim

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
    mini-bufremove
    mini-pairs
    mini-ai

    # Database
    vim-dadbod
    vim-dadbod-ui
    vim-dadbod-completion

    # AI
    render-markdown-nvim
    codecompanion-nvim
    codecompanion-spinner-nvim

    # Http client
    (kulala-nvim.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [
        ./patches/kulala-treesitter.patch
      ];
    }))
  ];

  extraPlugins = with pkgs; [
    # Direnv
    (vimUtils.buildVimPlugin {
      pname = "direnv";
      version = "2025-06-09";
      src = fetchFromGitHub {
        owner = "NotAShelf";
        repo = "direnv.nvim";
        rev = "4dfc8758a1deab45e37b7f3661e0fd3759d85788";
        sha256 = "sha256-KqO8uDbVy4sVVZ6mHikuO+SWCzWr97ZuFRC8npOPJIE=";
      };
      meta.homepage = "https://github.com/NotAShelf/direnv.nvim";
    })
    # Theme
    (vimUtils.buildVimPlugin {
      pname = "nordic";
      version = "2025-06-15";
      src = fetchFromGitHub {
        owner = "AlexvZyl";
        repo = "nordic.nvim";
        rev = "6afe957722fb1b0ec7ca5fbea5a651bcca55f3e1";
        sha256 = "sha256-NY4kjeq01sMTg1PZeVVa2Vle4KpLwWEv4y34cDQ6JMU=";
      };
      meta.homepage = "https://github.com/AlexvZyl/nordic.nvim";
    })
  ];
in

plugins ++ extraPlugins
