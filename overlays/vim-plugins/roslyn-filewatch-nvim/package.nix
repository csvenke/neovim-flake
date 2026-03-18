{
  vimUtils,
  fetchFromGitHub,
  fetchurl,
  stdenv,
}:

let
  platforms = {
    "x86_64-linux" = "linux-x86_64";
    "aarch64-linux" = "linux-x86_64";
    "x86_64-darwin" = "macos-arm64";
    "aarch64-darwin" = "macos-arm64";
  };

  hashes = {
    "x86_64-linux" = "sha256-ZkDw9lWRL8iuurGTYKNfJ7ad9PZl+jvyxUCGltMKOm0=";
    "aarch64-linux" = "sha256-ZkDw9lWRL8iuurGTYKNfJ7ad9PZl+jvyxUCGltMKOm0=";
    "x86_64-darwin" = "sha256-1bk8srpnbqy1x5k373pia5s840dfc4ph7kqywan57127j58hdr9a";
    "aarch64-darwin" = "sha256-1bk8srpnbqy1x5k373pia5s840dfc4ph7kqywan57127j58hdr9a";
  };

  system = stdenv.hostPlatform.system;

  platform = platforms.${system} or (throw "Unsupported system: ${system}.");

  hash = hashes.${system} or (throw "Unsupported system: ${system}.");

  version = "v0.4.7";

  roslynFilewatchRs = stdenv.mkDerivation {
    pname = "roslyn-filewatch-rs";
    inherit version;

    src = fetchurl {
      url = "https://github.com/khoido2003/roslyn-filewatch.nvim/releases/download/${version}/roslyn_filewatch_rs-${platform}.so";
      sha256 = hash;
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/lib
      cp $src $out/lib/roslyn_filewatch_rs.so
    '';

    meta = {
      description = "Native Rust backend for roslyn-filewatch.nvim";
      homepage = "https://github.com/khoido2003/roslyn-filewatch.nvim";
    };
  };
in

vimUtils.buildVimPlugin rec {
  pname = "roslyn-filewatch";
  inherit version;

  src = fetchFromGitHub {
    owner = "khoido2003";
    repo = "roslyn-filewatch.nvim";
    rev = version;
    sha256 = "sha256-qUi0djsXWs892Hp41gDTbXMeiS12Nfzhuh6Y4XOCGf8=";
  };

  postInstall = ''
    mkdir -p $out/lua
    cp ${roslynFilewatchRs}/lib/roslyn_filewatch_rs.so $out/lua/
  '';

  doCheck = false;

  meta.homepage = "https://github.com/khoido2003/roslyn-filewatch.nvim";
}
