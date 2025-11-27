{
  description = "neovim flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
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
              (import ./overlays/default.nix)
            ];
          };
          inherit (pkgs)
            callPackage
            runCommandLocal
            mkShell
            ;
          neovim = callPackage ./nix/neovim.nix {
            config = {
              name = "config";
              src = ./nvim;
              vimPlugins = callPackage ./nix/plugins.nix { };
              dependencies = callPackage ./nix/runtime.nix { };
            };
          };
          scripts = callPackage ./scripts.nix { };
        in
        {
          overlayAttrs = {
            inherit neovim;
          };
          packages = {
            default = neovim;
          };
          checks = {
            checkhealth = runCommandLocal "checkhealth" { } ''
              ${neovim}/bin/nvim --headless "+checkhealth" +qa | tee $out
            '';
            test = runCommandLocal "test" { } ''
              cd ${./.}
              ${neovim}/bin/nvim --headless -c "PlenaryBustedDirectory nvim/tests/ {minimal_init = 'nvim/tests/minimal_init.lua'}" | tee $out
            '';
            codequality = runCommandLocal "codequality" { nativeBuildInputs = scripts; } ''
              cd ${./.}
              format --check && lint | tee $out
            '';
          };
          devShells = {
            default = mkShell {
              packages = scripts;
            };
          };
        };
    };
}
