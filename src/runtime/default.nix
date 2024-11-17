{ pkgs }:

with pkgs;
[
  gcc
  ripgrep
  fd
  findutils
  gnutar
  fzf
  wget
  curl
  unzip
  gzip
  gnumake
  gnutar
  gnused
  gnugrep
  xdg-utils
  git
  lazygit
  xclip

  ### Lua ###
  lua-language-server
  stylua

  ### Nix ###
  nixd
  nixfmt-rfc-style

  ### Bash ###
  nodePackages.bash-language-server
  shfmt
  shellcheck

  ### Python ###
  (python3.withPackages (ps: [ ps.pip ps.pipx ]))
  pyright
  ruff

  ### Markdown ###
  marksman

  ### Yaml ###
  yaml-language-server

  ### TOML ###
  taplo

  ### Json, eslint, markdown, css, html ###
  vscode-langservers-extracted
  css-variables-language-server
  vscode-extensions.dbaeumer.vscode-eslint

  ### Prettier ###
  prettierd

  ### Javascript/Typescript ###
  nodePackages.typescript-language-server

  ### Angular
  angular-language-server

  ### Tailwindcss
  tailwindcss-language-server

  ### Dotnet
  csharpier
  omnisharp-roslyn
]

