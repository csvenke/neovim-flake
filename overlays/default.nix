final: prev:

{
  vimPlugins = prev.callPackage ./vimPlugins/package.nix { vimPlugins = prev.vimPlugins; };
}
