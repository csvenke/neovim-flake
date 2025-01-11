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
    src = ../src;
    dependencies = callPackage ./plugins.nix { };
    buildInputs = [ git ];
  };
  overrideNeovim = neovim.override {
    withNodeJs = false;
    withRuby = false;
    withPython3 = false;
    configure = {
      packages.all.start = [ config ];
      customRC = # vim
        ''
          lua require("config")
        '';
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
