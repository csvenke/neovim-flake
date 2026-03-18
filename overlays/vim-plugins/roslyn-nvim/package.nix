{
  vimPlugins,
}:

vimPlugins.roslyn-nvim.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [ ./patches/skip-virtual-buffers.patch ];
})
