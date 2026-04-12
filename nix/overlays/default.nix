final: prev:

let
  inherit (prev) lib;

  overrideVimPlugins = lib.packagesFromDirectoryRecursive {
    callPackage = lib.callPackageWith (prev // { vimPlugins = prev.vimPlugins; });
    directory = ./vim-plugins;
  };
in

{
  vimPlugins = prev.vimPlugins // overrideVimPlugins;
}
