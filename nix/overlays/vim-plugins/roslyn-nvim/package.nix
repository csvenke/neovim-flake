{
  vimPlugins,
  fetchFromGitHub,
  stdenv,
  fetchurl,
  unzip,
}:

let
  roslyn-razor-extension = stdenv.mkDerivation {
    pname = "roslyn-razor-extension";
    version = "10.0.0-preview.26179.2";

    src = fetchurl {
      url = "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/flat2/microsoft.visualstudiocode.razorextension/10.0.0-preview.26179.2/microsoft.visualstudiocode.razorextension.10.0.0-preview.26179.2.nupkg";
      hash = "sha256-qE+KHxjZhZD1AikvbSD+fRVqnz/pBX1d0Q+Ha3QmF/o=";
    };

    nativeBuildInputs = [ unzip ];

    unpackPhase = ''
      runHook preUnpack
      unzip $src
      runHook postUnpack
    '';

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r content/* $out/

      runHook postInstall
    '';
  };
in

vimPlugins.roslyn-nvim.overrideAttrs (oldAttrs: {
  src = fetchFromGitHub {
    owner = "seblyng";
    repo = "roslyn.nvim";
    rev = "b62d1a588765f0aa1b46ed260252c9e456408835";
    hash = "sha256-j5+Kg4B1flk4TwkZKRDW7tHbaoUyE5dKGypXsd9+qSw=";
  };

  postPatch =
    # bash
    ''
      substituteInPlace lua/roslyn/utils.lua \
        --replace-fail 'function M.find_razor_extension_path()' 'function M.find_razor_extension_path()
      local nix_razor_path = "${roslyn-razor-extension}"
      if vim.fn.isdirectory(nix_razor_path) == 1 then
          return nix_razor_path
      end'
    '';
})
