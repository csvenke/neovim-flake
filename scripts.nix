{
  writeShellApplication,
  stylua,
  luaPackages,
}:

{
  format = writeShellApplication {
    name = "format";
    runtimeInputs = [
      stylua
    ];
    text = ''
      stylua --glob '**/*.lua' --verify "$@" -- nvim
    '';
  };

  lint = writeShellApplication {
    name = "lint";
    runtimeInputs = [
      luaPackages.luacheck
    ];
    text = ''
      luacheck nvim
    '';
  };
}
