{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin rec {
  pname = "diffs";
  version = "330e2bc9b89ebcc52b77a9fa960541c0cfbca81d";
  src = fetchFromGitHub {
    owner = "barrettruth";
    repo = "diffs.nvim";
    rev = version;
    hash = "sha256-GBGReo17PgV1Ff6Rgmik4/wl6LGGo3+5NdYyv8+3Qe0=";
  };
  meta.homepage = "https://github.com/barrettruth/diffs.nvim";
}
