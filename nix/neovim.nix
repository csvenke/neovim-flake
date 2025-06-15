{
  callPackage,
  vimUtils,
}:

let
  mkNeovim = callPackage ./packages/mkNeovim.nix { };

  configAsPlugin = vimUtils.buildVimPlugin {
    name = "config";
    src = ../nvim;
    dependencies = callPackage ./plugins.nix { };
    buildInputs = callPackage ./runtime.nix { };
  };
in

mkNeovim {
  extraPlugins = [ configAsPlugin ];
  extraPackages = callPackage ./runtime.nix { };
}
