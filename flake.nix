{
  description = "neovim flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    css-variables-language-server = {
      url = "github:csvenke/css-variables-language-server-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      perSystem =
        { config, system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              inputs.css-variables-language-server.overlays.default
            ];
          };
          neovim = pkgs.callPackage ./nix/neovim.nix { };
        in
        {
          overlayAttrs = {
            inherit neovim;
          };
          packages = {
            default = neovim;
          };
          checks = {
            check-health =
              pkgs.runCommandLocal "check-health" { nativeBuildInputs = [ config.packages.default ]; }
                ''
                  nvim --headless "+checkhealth" +qa | tee $out
                '';
          };
        };
    };
}
