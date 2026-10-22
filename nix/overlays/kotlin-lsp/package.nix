{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  unzip,
  autoPatchelfHook,
  jdk25,
  zlib,
}:

let
  version = "263.7084.0";

  platformUrls = {
    x86_64-linux = "https://download.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}.tar.gz";
    aarch64-linux = "https://download.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}-aarch64.tar.gz";
    x86_64-darwin = "https://download.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}.sit";
    aarch64-darwin = "https://download.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}-aarch64.sit";
  };

  platformHashes = {
    x86_64-linux = "sha256-rgxLAeF6tzpKUienjqmebcvj5JlgAxWyJ1mk5M3dEd8=";
    aarch64-linux = "sha256-RQq3wdgOSBBqpCm0jLQibYLKEqiiQARHrgI4Z5R4DKw=";
    x86_64-darwin = "sha256-spw5Ol5UEVPQPWJueUYmhDfjWKZnpfkUoSbbtAB2ZLE=";
    aarch64-darwin = "sha256-tAO/ilS9RY47pnMc+KuzNAvgi0OcA1dt/AKxP682lLg=";
  };

  isDarwin = stdenv.hostPlatform.isDarwin;
in

stdenv.mkDerivation rec {
  pname = "kotlin-lsp";
  inherit version;

  src = fetchurl {
    url = platformUrls.${stdenv.hostPlatform.system};
    hash = platformHashes.${stdenv.hostPlatform.system};
    name = if isDarwin then "kotlin-server-${version}.zip" else null;
  };

  dontStrip = isDarwin;

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals isDarwin [ unzip ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    zlib
    stdenv.cc.cc.lib
  ];

  autoPatchelfIgnoreMissingDeps = lib.optionals stdenv.hostPlatform.isLinux [
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
    homepage = "https://github.com/Kotlin/kotlin-lsp";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "intellij-server";
  };
}
