{
  vimUtils,
  fetchFromGitHub,
  fetchurl,
  stdenv,
}:

let
  roslynFilewatchRs = stdenv.mkDerivation rec {
    pname = "roslyn-filewatch-rs";
    version = "v0.4.7";

    src = fetchurl {
      url =
        let
          platform =
            {
              "x86_64-linux" = "linux-x86_64";
              "aarch64-linux" = "linux-x86_64";
              "x86_64-darwin" = "macos-arm64";
              "aarch64-darwin" = "macos-arm64";
            }
            .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
        in
        "https://github.com/khoido2003/roslyn-filewatch.nvim/releases/download/${version}/roslyn_filewatch_rs-${platform}.so";

      sha256 =
        if stdenv.isLinux && stdenv.isx86_64 then
          "sha256-ZkDw9lWRL8iuurGTYKNfJ7ad9PZl+jvyxUCGltMKOm0="
        else if stdenv.isDarwin && stdenv.isAarch64 then
          "sha256-PLACEHOLDER_MACOS_ARM"
        else if stdenv.isDarwin && stdenv.isx86_64 then
          "sha256-PLACEHOLDER_MACOS_X86"
        else
          throw "Unsupported platform";
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
  version = "v0.4.7";

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
