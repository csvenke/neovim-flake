{
  vimPlugins,
  neovimUtils,
  fetchFromGitHub,
  tree-sitter,
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

vimPlugins.kulala-nvim.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    ./patches/kulala-treesitter.patch
  ];
  dependencies = (oldAttrs.dependencies or [ ]) ++ [ kulala-http-grammar ];
})
