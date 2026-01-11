{
  vimUtils,
  vimPlugins,
  fetchFromGitHub,
  nix-update-script,
  cmake,
}:

vimUtils.buildVimPlugin rec {
  pname = "codediff-nvim";
  version = "2.9.1";
  src = fetchFromGitHub {
    owner = "esmuellert";
    repo = "codediff.nvim";
    rev = "v${version}";
    sha256 = "sha256-xIm3/Dxn77rRtUwaKE+3xed8Yyrfnte/aroRcgqiuXM=";
  };
  dependencies = [ vimPlugins.nui-nvim ];
  nativeBuildInputs = [ cmake ];
  dontUseCmakeConfigure = true;
  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';
  passthru.updateScript = nix-update-script { };
  meta.homepage = "https://github.com/esmuellert/codediff.nvim";
}
