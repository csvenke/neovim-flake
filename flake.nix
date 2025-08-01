{
  description = "neovim flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
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
        { system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              inputs.neovim-nightly-overlay.overlays.default
            ];
          };
          neovim = pkgs.callPackage ./nix/neovim.nix { };
          scripts = pkgs.callPackage ./scripts.nix { };
        in
        {
          overlayAttrs = {
            inherit neovim;
          };
          packages = {
            default = neovim;
          };
          checks = {
            checkhealth = pkgs.runCommandLocal "checkhealth" { } ''
              ${neovim}/bin/nvim --headless "+checkhealth" +qa | tee $out
            '';
            codequality =
              pkgs.runCommandLocal "codequality"
                {
                  nativeBuildInputs = [
                    scripts.format
                    scripts.lint
                  ];
                }
                ''
                  cd ${./.}
                  format --check && lint
                  mkdir -p $out
                '';
          };
          devShells = {
            default = pkgs.mkShell {
              packages = [
                scripts.format
                scripts.lint
              ];
            };
          };
        };
    };
}
