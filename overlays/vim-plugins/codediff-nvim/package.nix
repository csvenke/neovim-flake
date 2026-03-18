{
  vimPlugins,
}:

vimPlugins.codediff-nvim.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [ ./patches/skip-roslyn-semantic-tokens.patch ];
})
