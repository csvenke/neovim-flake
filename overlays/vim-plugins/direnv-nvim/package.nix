{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin rec {
  pname = "direnv";
  version = "4dfc8758a1deab45e37b7f3661e0fd3759d85788";
  src = fetchFromGitHub {
    owner = "NotAShelf";
    repo = "direnv.nvim";
    rev = version;
    sha256 = "sha256-KqO8uDbVy4sVVZ6mHikuO+SWCzWr97ZuFRC8npOPJIE=";
  };
  meta.homepage = "https://github.com/NotAShelf/direnv.nvim";
}
