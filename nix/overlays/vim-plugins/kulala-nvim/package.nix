{
  vimPlugins,
  neovimUtils,
  fetchFromGitHub,
  tree-sitter,
}:

let
  version = "5.3.3";
  rev = "9fc4831a116fb32b0fd420ed483f5102a873446a";

  src = fetchFromGitHub {
    owner = "mistweaverco";
    repo = "kulala.nvim";
    inherit rev;
    hash = "sha256-YRHPx4KPrVtXbYinKOFQmO3SI1cC/+siUtzNWjfTCf8=";
  };

  kulala-http-grammar = neovimUtils.grammarToPlugin (
    tree-sitter.buildGrammar {
      language = "kulala_http";
      inherit version src;
      location = "lua/tree-sitter";
      generate = false;
      meta.homepage = "https://github.com/mistweaverco/kulala.nvim";
    }
  );
in

vimPlugins.kulala-nvim.overrideAttrs (oldAttrs: {
  inherit version src;
  patches = [ ./patches/kulala-treesitter.patch ];
  dependencies = (oldAttrs.dependencies or [ ]) ++ [ kulala-http-grammar ];
})
