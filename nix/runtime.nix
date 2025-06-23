{ pkgs, callPackage }:

with pkgs;
[
  ### Core ###
  gcc
  ripgrep
  fd
  findutils
  gnutar
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

  ### Telescope ###
  fzf

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
  typescript-language-server

  ### Angular ###
  (callPackage ./packages/ngserver.nix { })

  ### Tailwindcss ###
  tailwindcss-language-server

  ### Dotnet ###
  csharpier
  omnisharp-roslyn
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
