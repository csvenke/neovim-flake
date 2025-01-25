{
  callPackage,
  vimUtils,
  git,
}:

let
  mkNeovim = callPackage ./packages/mkNeovim.nix { };

  configAsPlugin = vimUtils.buildVimPlugin {
    name = "config";
    src = ../nvim;
    dependencies = callPackage ./plugins.nix { };
    buildInputs = [ git ];
  };
in

mkNeovim {
  extraPlugins = [ configAsPlugin ];
  extraPackages = callPackage ./runtime.nix { };
}
