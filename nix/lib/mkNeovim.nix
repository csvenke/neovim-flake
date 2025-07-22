{
  lib,
  wrapNeovimUnstable,
  neovimUtils,
  neovim-unwrapped,
  vimUtils,
}:

{
  extraConfig,
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
        name = "config";
        src = extraConfig;
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
