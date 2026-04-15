{
  lib,
  stdenv,
  roslynLs,
}:

roslynLs.overrideAttrs (oldAttrs: {
  patches =
    (oldAttrs.patches or [ ])
    ++ lib.optionals stdenv.isLinux [
      ./patches/linux-filewatching-workaround.patch
    ];
})
