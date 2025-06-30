{ pkgs }:

{
  format = pkgs.writeShellApplication {
    name = "format";
    runtimeInputs = with pkgs; [
      stylua
    ];
    text = ''
      stylua --glob '**/*.lua' "$@" -- nvim/lua
    '';
  };

  lint = pkgs.writeShellApplication {
    name = "lint";
    runtimeInputs = with pkgs; [
      luaPackages.luacheck
    ];
    text = ''
      luacheck nvim/lua
    '';
  };
}
