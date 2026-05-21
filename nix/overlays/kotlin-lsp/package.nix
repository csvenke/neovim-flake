{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  jdk25,
  zlib,
}:

let
  version = "262.4739.0";

  platformUrls = {
    x86_64-linux = "https://download-cdn.jetbrains.com/kotlin-lsp/${version}/kotlin-server-${version}.tar.gz";
    aarch64-linux = "https://download-cdn.jetbrains.com/kotlin-lsp/${version}/kotlin-server-${version}-aarch64.tar.gz";
  };

  platformHashes = {
    x86_64-linux = "sha256-RpcREMm4ozYM4/31Q3Rn9MRH2tN61z2/gdZK9neeQQU=";
    aarch64-linux = "sha256-YlhwrgkcbQ3uJVFNVFxwim6lDXy7UVSq8aqRI8z/M4s=";
  };
in

stdenv.mkDerivation rec {
  pname = "kotlin-lsp";
  inherit version;

  src = fetchurl {
    url = platformUrls.${stdenv.hostPlatform.system};
    hash = platformHashes.${stdenv.hostPlatform.system};
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
    stdenv.cc.cc.lib
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libasound.so.2"
    "libX11.so.6"
    "libXext.so.6"
    "libXi.so.6"
    "libXrender.so.1"
    "libXtst.so.6"
    "libfreetype.so.6"
    "libwayland-client.so.0"
    "libwayland-cursor.so.0"
    "libxkbcommon.so.0"
    "libc.musl-x86_64.so.1"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -r . $out/lib/

    mkdir -p $out/bin
    makeWrapper $out/lib/bin/intellij-server $out/bin/intellij-server \
      --prefix PATH : ${lib.makeBinPath [ jdk25 ]}

    runHook postInstall
  '';

  meta = {
    description = "Official Kotlin LSP from JetBrains";
    homepage = "https://github.com/JetBrains/kotlin-lsp";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "intellij-server";
  };
}
