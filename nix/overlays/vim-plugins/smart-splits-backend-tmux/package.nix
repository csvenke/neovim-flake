{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin rec {
  pname = "smart-splits-backend-tmux";
  version = "9e9e6aa9b3eb7a8d3896a993611622ac97abff52";
  src = fetchFromGitHub {
    owner = "smart-splits-nvim";
    repo = "backend-tmux";
    rev = version;
    sha256 = "sha256-RcJdM6wFHZOEOK+cXVIT10anktqGgIilPmojFpdY+4g=";
  };
  meta.homepage = "https://github.com/smart-splits-nvim/backend-tmux";
}
