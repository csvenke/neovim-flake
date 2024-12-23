{ pkgs }:

let
  runtime = pkgs.callPackage ./runtime.nix { };
  plugins = pkgs.callPackage ./plugins.nix { };
  config = pkgs.vimUtils.buildVimPlugin {
    name = "config";
    src = ./config;
  };

  overrideNeovim = pkgs.neovim.override {
    configure = {
      packages.all.start = plugins ++ [ config ];
    };
  };
in

pkgs.writeShellApplication {
  name = "nvim";
  runtimeInputs = runtime;
  text = ''
    ${overrideNeovim}/bin/nvim "$@"
  '';
}
