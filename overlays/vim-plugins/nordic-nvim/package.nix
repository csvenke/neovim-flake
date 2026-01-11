{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin rec {
  pname = "nordic";
  version = "4f0245ed32a32436b2c6ae1a03f625a93a8c077a";
  src = fetchFromGitHub {
    owner = "AlexvZyl";
    repo = "nordic.nvim";
    rev = version;
    sha256 = "sha256-Mm+2VDpWc3abY4EUpg3f+kVjtEE/IZvRbPSxh9BjyfA=";
  };
  meta.homepage = "https://github.com/AlexvZyl/nordic.nvim";
}
