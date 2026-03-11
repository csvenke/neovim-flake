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

  tree-sitter-cli = prev.tree-sitter.overrideAttrs (old: rec {
    version = "0.26.1";
    src = prev.fetchFromGitHub {
      owner = "tree-sitter";
      repo = "tree-sitter";
      rev = "v0.26.1";
      hash = "sha256-k8X2qtxUne8C6znYAKeb4zoBf+vffmcJZQHUmBvsilA=";
    };
    cargoDeps = prev.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-hnFHYQ8xPNFqic1UYygiLBWu3n82IkTJuQvgcXcMdv0=";
    };
    patches = [ ];
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.rustPlatform.bindgenHook ];
  });
}
