{
  description = "neovim flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-gen-luarc-json = {
      url = "github:mrcjkb/nix-gen-luarc-json";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.treefmt-nix.flakeModule
        ./nix/flake/formatting.nix
        ./nix/flake/checks.nix
        ./nix/flake/dev-shells.nix
      ];
      perSystem =
        { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              (import ./nix/overlays/default.nix)
              inputs.nix-gen-luarc-json.overlays.default
            ];
          };
          inherit (pkgs) callPackage;

          plugins = callPackage ./nix/plugins.nix { };
          runtimeDeps = callPackage ./nix/runtimeDeps.nix { };
          neovim = callPackage ./nix/neovim.nix {
            src = ./nvim;
            inherit plugins runtimeDeps;
          };

          neovide = pkgs.neovide.overrideAttrs {
            inherit neovim;
          };
        in
        {
          _module.args.pkgs = pkgs;
          _module.args.neovim = neovim;
          _module.args.plugins = plugins;

          overlayAttrs = {
            inherit neovim neovide;
          };

          packages = {
            default = neovim;
            inherit neovim neovide;
          };
        };
    };
}
