{
  description = "neovim flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    vim-extra-plugins.url = "github:jooooscha/nixpkgs-vim-extra-plugins";
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      perSystem = { pkgs, system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              inputs.vim-extra-plugins.overlays.default
            ];
          };
          neovim = import ./src {
            inherit pkgs;
          };
        in
        {
          overlayAttrs = {
            inherit neovim;
          };
          packages = {
            default = neovim;
          };
        };
    };
}
