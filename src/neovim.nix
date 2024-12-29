{
  neovim,
  vimUtils,
  callPackage,
  writeShellApplication,
}:

let
  config = vimUtils.buildVimPlugin {
    name = "config";
    src = ./config;
    dependencies = callPackage ./plugins.nix { };
  };
  overrideNeovim = neovim.override {
    configure = {
      packages.all.start = [ config ];
    };
  };
in

writeShellApplication {
  name = "nvim";
  runtimeInputs = callPackage ./runtime.nix { };
  text = ''
    ${overrideNeovim}/bin/nvim "$@"
  '';
}
