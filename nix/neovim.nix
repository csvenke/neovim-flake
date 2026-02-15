{
  lib,
  writeText,
  wrapNeovimUnstable,
  neovimUtils,
  neovim-unwrapped,
  src,
  plugins,
  runtimeDeps,
}:

let
  disableBuiltinPlugins = writeText "disable-builtin-plugins.lua" /* lua */ ''
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.g.loaded_tarPlugin = 1
    vim.g.loaded_zipPlugin = 1
    vim.g.loaded_matchparen = 1
    vim.g.loaded_tutor_mode_plugin = 1
    vim.g.loaded_2html_plugin = 1
    vim.g.loaded_remote_plugins = 1
    vim.g.loaded_getscript = 1
    vim.g.loaded_getscriptPlugin = 1
    vim.g.loaded_vimball = 1
    vim.g.loaded_vimballPlugin = 1
    vim.g.loaded_logiPat = 1
    vim.g.loaded_rrhelper = 1
  '';

  neovimConfig =
    neovimUtils.makeNeovimConfig {
      withNodeJs = false;
      withPython3 = false;
      withRuby = false;
      wrapRc = true;
      customRC = /* vim */ ''
        set runtimepath^=${src}
        set runtimepath+=${src}/after
      '';
      inherit plugins;
    }
    // {
      wrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        (lib.makeBinPath runtimeDeps)
        "--add-flags"
        "--cmd 'luafile ${disableBuiltinPlugins}'"
      ];
    };
in

wrapNeovimUnstable neovim-unwrapped neovimConfig
