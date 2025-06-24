{
  lib,
  wrapNeovimUnstable,
  neovimUtils,
  neovim-unwrapped,
  vimUtils,
}:

{
  lua,
  name,
  extraPlugins ? [ ],
  extraPackages ? [ ],
}:

let
  neovimConfig = neovimUtils.makeNeovimConfig {
    withNodeJs = false;
    withRuby = false;
    withPython3 = false;
    plugins = [
      (vimUtils.buildVimPlugin {
        name = name;
        src = lua;
        dependencies = extraPlugins;
        buildInputs = extraPackages;
      })
    ];
  };
  wrappedNeovim = wrapNeovimUnstable neovim-unwrapped neovimConfig;
in

wrappedNeovim.override (attrs: {
  wrapperArgs = attrs.wrapperArgs ++ [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath extraPackages}"
  ];
})
