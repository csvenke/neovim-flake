final: prev:

let
  inherit (prev) lib;

  overrideVimPlugins = lib.packagesFromDirectoryRecursive {
    inherit (prev) callPackage;
    directory = ./vim-plugins;
  };
in

{
  vimPlugins = prev.vimPlugins // overrideVimPlugins;

  kotlin-lsp = prev.callPackage ./kotlin-lsp/package.nix { };

  gleam = prev.gleam.overrideAttrs { doCheck = false; };
}
