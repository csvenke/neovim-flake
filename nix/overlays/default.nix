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

  kotlin-lsp = prev.callPackage ./kotlin-lsp/package.nix { };

  gleam = prev.gleam.overrideAttrs { doCheck = false; };

  # FIXME: remove once nixos-unstable includes the fixed pnpmDeps hash
  typescript-language-server = prev.typescript-language-server.overrideAttrs (old: {
    pnpmDeps = prev.fetchPnpmDeps {
      inherit (old) pname version src;
      pnpm = prev.pnpm_12;
      fetcherVersion = 4;
      hash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
    };
  });
}
