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

  roslyn-ls = prev.callPackage ./roslyn-ls/package.nix {
    roslynLs = prev.roslyn-ls;
  };

  css-variables-language-server = prev.callPackage ./css-variables-language-server/package.nix { };
}
