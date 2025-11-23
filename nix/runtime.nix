{ pkgs }:

with pkgs;
[
  ### Core ###
  gcc
  ripgrep
  fd
  findutils
  wget
  curl
  unzip
  gzip
  gnumake
  gnutar
  gnused
  gnugrep
  xdg-utils
  xclip

  ### Direnv ###
  direnv
  nix-direnv

  ### Http client ###
  jq
  grpcurl
  websocat
  libxml2
  openssl

  ### Git ###
  git

  ### Lua ###
  lua-language-server
  stylua

  ### Nix ###
  nixd
  nixfmt-rfc-style

  ### Bash ###
  bash-language-server
  shfmt
  shellcheck

  ### Python ###
  (python3.withPackages (ps: [
    ps.pip
    ps.pipx
  ]))
  pyright
  ruff

  ### kdl ###
  kdlfmt

  ### Markdown ###
  marksman

  ### Yaml ###
  yaml-language-server

  ### TOML ###
  taplo

  ### Json, eslint, markdown, css, html ###
  vscode-langservers-extracted
  vscode-extensions.dbaeumer.vscode-eslint

  ### Prettier ###
  prettierd

  ### Javascript/Typescript ###
  typescript-language-server

  ### Angular ###
  angular-language-server

  ### Tailwindcss ###
  tailwindcss-language-server

  ### Dotnet ###
  csharpier
  roslyn-ls
  netcoredbg

  ### Java ###
  jdt-language-server

  ### Haskell ###
  haskell-language-server

  ### Rust ###
  rust-analyzer

  ### Database ###
  sqlcmd
]
