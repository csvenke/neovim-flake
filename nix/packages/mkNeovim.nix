{
  lib,
  wrapNeovimUnstable,
  neovimUtils,
  neovim-unwrapped,
}:

{
  extraPlugins ? [ ],
  extraPackages ? [ ],
}:

let
  neovimConfig = neovimUtils.makeNeovimConfig {
    withNodeJs = false;
    withRuby = false;
    withPython3 = false;
    plugins = extraPlugins;
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
