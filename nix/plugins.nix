{ pkgs }:

with pkgs.vimPlugins;

[
  plenary-nvim
  guess-indent-nvim

  # Treesitter
  nvim-treesitter.withAllGrammars
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
  kulala-nvim

  # Direnv
  direnv-nvim

  # Theme
  nordic-nvim
]
