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
      version = "8676a4ffc654d9f9404b343982390bea568da737";
      src = fetchFromGitHub {
        owner = "mistweaverco";
        repo = "kulala.nvim";
        rev = version;
        sha256 = "sha256-TXbcy4Pjth9FfBcgnESuSQzdqRsRI5nPUocbNbpV8g4=";
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
