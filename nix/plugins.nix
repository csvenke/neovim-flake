{ pkgs }:

with pkgs.vimPlugins;

[
  # Plugin dependencies
  plenary-nvim
  nui-nvim
  nvim-nio
  nvim-web-devicons
  nvim-notify

  # theme.lua
  nordic-nvim

  # alpha.lua
  alpha-nvim

  # conform.lua
  conform-nvim

  # dadbod.lua
  vim-dadbod
  vim-dadbod-completion
  vim-dadbod-ui

  # debug/
  nvim-dap
  nvim-dap-ui
  nvim-dap-virtual-text

  # diffview.lua
  diffview-nvim

  # direnv.lua
  direnv-nvim

  # fidget.lua
  fidget-nvim

  # flash.lua
  flash-nvim

  # gitsigns.lua
  gitsigns-nvim

  # guess-indent.lua
  guess-indent-nvim

  # grapple.lua
  grapple-nvim

  # kulala.lua
  kulala-nvim

  # lsp/init.lua
  nvim-lspconfig
  SchemaStore-nvim
  ## Completion
  blink-cmp
  friendly-snippets
  ## Language specific
  nvim-jdtls
  roslyn-nvim

  # lualine.lua
  lualine-nvim

  # mini.lua
  mini-ai
  mini-bufremove
  mini-pairs

  # noice.lua
  noice-nvim

  # oil.lua
  oil-nvim

  # smart-splits.lua
  smart-splits-nvim

  # telescope/init.lua
  telescope-nvim
  telescope-fzf-native-nvim
  telescope-ui-select-nvim

  # treesitter.lua
  nvim-treesitter.withAllGrammars
  nvim-treesitter.passthru.queries.html_tags
  nvim-treesitter.passthru.queries.ecma
  nvim-treesitter.passthru.queries.jsx
  nvim-treesitter-context
  nvim-ts-autotag

  # which-key.lua
  which-key-nvim

  # no-neck-pain.lua
  no-neck-pain-nvim

  # fugitive.lua
  vim-fugitive

  # opencode.lua
  opencode-nvim
]
