{ ... }:

{
  perSystem =
    {
      pkgs,
      neovim,
      plugins,
      ...
    }:
    let
      inherit (pkgs) mkShell luaPackages mk-luarc-json;

      luarc = mk-luarc-json {
        nvim = neovim;
        inherit plugins;
        disabled-diagnostics = [
          "missing-fields"
          "duplicate-doc-field"
        ];
      };
    in
    {
      devShells = {
        default = mkShell {
          packages = [
            luaPackages.luacheck
          ];
          shellHook =
            # bash
            ''
              ln -fs ${luarc} .luarc.json
            '';
        };
      };
    };
}
