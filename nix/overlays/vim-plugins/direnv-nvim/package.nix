{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin rec {
  pname = "direnv";
  version = "564146278b3d5fe4ffa389cd103bab20f9b515d6";
  src = fetchFromGitHub {
    owner = "NotAShelf";
    repo = "direnv.nvim";
    rev = version;
    sha256 = "sha256-JbnGoZMApLtq4lSdGolcpKdsneolSOrzIi+O5yR2NDQ=";
  };
  meta.homepage = "https://github.com/NotAShelf/direnv.nvim";
}
