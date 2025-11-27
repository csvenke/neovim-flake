{
  writeShellApplication,
  stylua,
  luaPackages,
}:

[
  (writeShellApplication {
    name = "format";
    runtimeInputs = [
      stylua
    ];
    text = ''
      stylua --glob '**/*.lua' --verify "$@" -- nvim
    '';
  })

  (writeShellApplication {
    name = "lint";
    runtimeInputs = [
      luaPackages.luacheck
    ];
    text = ''
      luacheck nvim
    '';
  })
]
