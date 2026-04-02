{ ... }:

{
  perSystem =
    {
      config,
      neovim,
      pkgs,
      plugins,
      ...
    }:
    let
      luarc = pkgs.mk-luarc-json {
        nvim = neovim;
        inherit plugins;
        disabled-diagnostics = [
          "missing-fields"
          "duplicate-doc-field"
        ];
      };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = [
          config.treefmt.build.wrapper
          pkgs.luaPackages.luacheck
        ];
        shellHook =
          # bash
          ''
            ln -fs ${luarc} .luarc.json
          '';
      };
    };
}
