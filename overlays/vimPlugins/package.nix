{
  neovimUtils,
  tree-sitter,
  vimUtils,
  fetchFromGitHub,
  vimPlugins,
}:

let
  kulala-http-grammar = neovimUtils.grammarToPlugin (
    tree-sitter.buildGrammar rec {
      language = "kulala_http";
      version = "c328aeb219c4b77106917dd2698c90ea9657281b";
      src = fetchFromGitHub {
        owner = "mistweaverco";
        repo = "kulala.nvim";
        rev = version;
        sha256 = "12vxb24lqw5vpwfy57jd55461wmr6cyg2nq4mh1wk5jvhidlc1im";
      };
      location = "lua/tree-sitter";
      generate = false;
      meta.homepage = "https://github.com/mistweaverco/kulala.nvim";
    }
  );
in

vimPlugins
// {
  kulala-nvim = vimPlugins.kulala-nvim.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ./patches/kulala-treesitter.patch
    ];
    dependencies = (oldAttrs.dependencies or [ ]) ++ [ kulala-http-grammar ];
  });

  direnv-nvim = vimUtils.buildVimPlugin rec {
    pname = "direnv";
    version = "4dfc8758a1deab45e37b7f3661e0fd3759d85788";
    src = fetchFromGitHub {
      owner = "NotAShelf";
      repo = "direnv.nvim";
      rev = version;
      sha256 = "sha256-KqO8uDbVy4sVVZ6mHikuO+SWCzWr97ZuFRC8npOPJIE=";
    };
    meta.homepage = "https://github.com/NotAShelf/direnv.nvim";
  };

  nordic-nvim = vimUtils.buildVimPlugin rec {
    pname = "nordic";
    version = "6afe957722fb1b0ec7ca5fbea5a651bcca55f3e1";
    src = fetchFromGitHub {
      owner = "AlexvZyl";
      repo = "nordic.nvim";
      rev = version;
      sha256 = "sha256-NY4kjeq01sMTg1PZeVVa2Vle4KpLwWEv4y34cDQ6JMU=";
    };
    meta.homepage = "https://github.com/AlexvZyl/nordic.nvim";
  };
}
