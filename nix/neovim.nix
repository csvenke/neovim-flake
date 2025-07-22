{ callPackage }:

let
  mkNeovim = callPackage ./lib/mkNeovim.nix { };
in

mkNeovim {
  extraConfig = ../nvim;
  extraPlugins = callPackage ./plugins.nix { };
  extraPackages = callPackage ./runtime.nix { };
}
