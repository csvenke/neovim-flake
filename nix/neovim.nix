{
  lib,
  wrapNeovimUnstable,
  neovimUtils,
  neovim-unwrapped,
  vimUtils,
  config,
}:

assert config ? name || throw "config is missing name";
assert config ? src || throw "config is missing src";
assert config ? vimPlugins || throw "config is missing vimPlugins";
assert config ? dependencies || throw "config is missing dependencies";

let
  configAsPlugin = vimUtils.buildVimPlugin {
    name = config.name;
    src = config.src;
    dependencies = config.vimPlugins;
    buildInputs = config.dependencies;
  };

  neovimConfig =
    neovimUtils.makeNeovimConfig {
      withNodeJs = false;
      withPython3 = false;
      withRuby = false;
      wrapRc = false;
      plugins = [ configAsPlugin ];
    }
    // {
      wrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        (lib.makeBinPath config.dependencies)
      ];
    };
in

wrapNeovimUnstable neovim-unwrapped neovimConfig
