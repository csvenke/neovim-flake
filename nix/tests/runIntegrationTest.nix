{
  lib,
  neovim,
  helperSrc,
  hermeticTestEnv,
  integrationFixtureRoot,
  integrationSpecRoot,
  runCommandLocal,
}:

{
  name,
  spec,
  fixture ? null,
  openFile ? null,
  extraPath ? [ ],
  extraEnv ? { },
  preflight ? "",
}:

let
  resolvePath = root: value: if builtins.typeOf value == "path" then value else root + "/${value}";
  resolvedFixture = if fixture == null then null else resolvePath integrationFixtureRoot fixture;
  resolvedSpec = resolvePath integrationSpecRoot spec;
in

runCommandLocal name { } ''
  set -euo pipefail

  ${hermeticTestEnv { withWorkspace = true; }}

  ${lib.optionalString (resolvedFixture != null) ''
    cp -R ${resolvedFixture}/. "$workspace"/
    chmod -R u+w "$workspace"
  ''}

  export INTEGRATION_TEST_WORKSPACE_ROOT="$workspace"
  ${lib.optionalString (openFile != null) ''
    export INTEGRATION_TEST_OPEN_FILE=${lib.escapeShellArg openFile}
  ''}
  ${lib.concatStringsSep "\n" (
    lib.mapAttrsToList (envName: envValue: "export ${envName}=${lib.escapeShellArg envValue}") extraEnv
  )}
  ${lib.optionalString (extraPath != [ ]) ''
    export PATH=${lib.escapeShellArg (lib.makeBinPath extraPath)}:$PATH
  ''}

  cd "$workspace"
  ${preflight}
  ${neovim}/bin/nvim --headless \
    -c ${lib.escapeShellArg "set runtimepath^=${helperSrc}"} \
    -c ${lib.escapeShellArg "set runtimepath+=${helperSrc}/after"} \
    -c ${lib.escapeShellArg ''lua require("plenary.busted").run("${resolvedSpec}")''} \
    2>&1 | tee "$out"
''
