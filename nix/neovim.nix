{
  lib,
  wrapNeovimUnstable,
  neovimUtils,
  neovim-unwrapped,
  vimUtils,
  neovimConfig,
}:

assert neovimConfig ? name || throw "neovimConfig is missing name";
assert neovimConfig ? src || throw "neovimConfig is missing src";
assert neovimConfig ? vimPlugins || throw "neovimConfig is missing vimPlugins";
assert neovimConfig ? dependencies || throw "neovimConfig is missing dependencies";

let
  makeNeovim =
    vimPlugins: dependencies:
    wrapNeovimUnstable neovim-unwrapped (
      neovimUtils.makeNeovimConfig { plugins = vimPlugins; }
      // {
        wrapperArgs = [
          "--prefix"
          "PATH"
          ":"
          (lib.makeBinPath dependencies)
        ];
      }
    );

  testNeovim = makeNeovim neovimConfig.vimPlugins [ ];

  configAsPlugin = vimUtils.buildVimPlugin {
    name = neovimConfig.name;
    src = neovimConfig.src;
    doCheck = true;
    dependencies = neovimConfig.vimPlugins;
    buildInputs = neovimConfig.dependencies;
    nativeCheckInputs = [ testNeovim ];
    checkPhase = ''
      runHook preCheck
      export HOME=$(mktemp -d)
      nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"
      runHook postCheck
    '';
  };
in

makeNeovim [ configAsPlugin ] neovimConfig.dependencies
