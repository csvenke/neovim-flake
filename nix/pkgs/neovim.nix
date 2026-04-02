{
  lib,
  wrapNeovimUnstable,
  neovim-unwrapped,
  src,
  plugins,
  runtimeDeps,
}:

wrapNeovimUnstable neovim-unwrapped {
  withNodeJs = false;
  withPython3 = false;
  withRuby = false;
  wrapRc = true;
  neovimRcContent = /* vim */ ''
    set runtimepath^=${src}
    set runtimepath+=${src}/after
  '';
  inherit plugins;
  wrapperArgs = [
    "--set-default"
    "NVIM_APPNAME"
    "neovim-flake"
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath runtimeDeps)
  ];
}
