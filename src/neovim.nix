{
  neovim,
  git,
  vimUtils,
  callPackage,
  writeShellApplication,
}:

let
  config = vimUtils.buildVimPlugin {
    name = "config";
    src = ./config;
    dependencies = callPackage ./plugins.nix { };
    buildInputs = [ git ];
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
