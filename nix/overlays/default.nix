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

  css-variables-language-server = prev.callPackage ./css-variables-language-server/package.nix { };

  kotlin-lsp = prev.callPackage ./kotlin-lsp/package.nix { };

  gleam = prev.gleam.overrideAttrs { doCheck = false; };

  # https://github.com/NixOS/nixpkgs/issues/531366
  vscode-langservers-extracted = prev.vscode-langservers-extracted.overrideAttrs (oldAttrs: {
    postFixup = ''
      for f in $out/lib/node_modules/vscode-langservers-extracted/lib/*/node/*.js; do
        if [ -f "$f" ]; then
          sed -i 's/import\.meta\.url/__filename/g' "$f"
        fi
      done
    ''
    + (oldAttrs.postFixup or "");
  });
}
