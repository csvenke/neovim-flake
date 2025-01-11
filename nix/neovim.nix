{
  neovim,
  git,
  vimUtils,
  vimPlugins,
  callPackage,
  symlinkJoin,
  writeShellApplication,
}:

let
  joinedParsers = symlinkJoin {
    name = "neovim-parsers";
    paths = vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
  };
  joinedPlugins = symlinkJoin {
    name = "neovim-plugins";
    paths = callPackage ./plugins.nix { };
  };
  joinedRuntime = symlinkJoin {
    name = "neovim-runtime";
    paths = callPackage ./runtime.nix { };
  };
  config = vimUtils.buildVimPlugin {
    name = "config";
    src = ../src;
    dependencies = [ joinedPlugins ];
    buildInputs = [ git ];
  };
  overrideNeovim = neovim.override {
    withNodeJs = false;
    withRuby = false;
    withPython3 = false;
    configure = {
      packages.all.start = [ config ];
      customRC = # vim
        ''
          lua vim.opt.runtimepath:prepend("${joinedParsers}")
          lua require("config")
        '';
    };
  };
in

writeShellApplication {
  name = "nvim";
  runtimeInputs = [ joinedRuntime ];
  text = ''
    ${overrideNeovim}/bin/nvim "$@"
  '';
}
