{ pkgs }:

let
  plugins = with pkgs.vimPlugins; [
    direnv-vim
    # Treesitter
    nvim-treesitter.withAllGrammars
    nvim-treesitter-textobjects
    nvim-treesitter-refactor
    nvim-treesitter-context
    nvim-ts-autotag
    # LSP
    fidget-nvim
    neodev-nvim
    neoconf-nvim
    nvim-lspconfig
    omnisharp-extended-lsp-nvim
    nvim-jdtls
    # Autocomplete
    friendly-snippets
    luasnip
    cmp-nvim-lsp
    cmp-buffer
    cmp-path
    cmp-cmdline
    cmp_luasnip
    nvim-cmp
    # Formatting
    conform-nvim
    # Telescope
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
    noice-nvim
    trouble-nvim
    lualine-nvim
    nvim-notify
    which-key-nvim
    # Navigation
    oil-nvim
    harpoon2
    neo-tree-nvim
    # Startup
    alpha-nvim
    vim-startuptime
    # Utils
    smart-splits-nvim
    SchemaStore-nvim
    mini-nvim
    nui-nvim
    plenary-nvim
    vim-sleuth
    # Icons
    lspkind-nvim
    nvim-web-devicons
  ];

  # https://github.com/NixNeovim/NixNeovimPlugins
  extraPlugins = with pkgs.vimExtraPlugins; [
    # Themes
    nordic-alexczyl
    # LLMs
    gp-nvim
  ];

  # Plugins not found in vimPlugins and vimExtraPlugins
  manualPlugins = with pkgs.vimUtils; [
    # Git
    (buildVimPlugin {
      pname = "git-worktree.nvim";
      version = "2024-06-07";
      src = pkgs.fetchFromGitHub {
        owner = "polarmutex";
        repo = "git-worktree.nvim";
        rev = "500629d0ad916ec362f53ecf21f84f3ba445f73e";
        sha256 = "db5z9j+HTPcOeBjnX8T7syLt4zNDvm45V0lXrD8q6oY=";
      };
    })
  ];
in

plugins ++ extraPlugins ++ manualPlugins
