{ callPackage }:

let
  configureNeovim = callPackage ./lib/configureNeovim.nix { };
in

configureNeovim {
  name = "config";
  lua = ../nvim;
  extraPlugins = callPackage ./plugins.nix { };
  extraPackages = callPackage ./runtime.nix { };
}
