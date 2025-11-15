{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin rec {
  pname = "nordic";
  version = "6afe957722fb1b0ec7ca5fbea5a651bcca55f3e1";
  src = fetchFromGitHub {
    owner = "AlexvZyl";
    repo = "nordic.nvim";
    rev = version;
    sha256 = "sha256-NY4kjeq01sMTg1PZeVVa2Vle4KpLwWEv4y34cDQ6JMU=";
  };
  meta.homepage = "https://github.com/AlexvZyl/nordic.nvim";
}
