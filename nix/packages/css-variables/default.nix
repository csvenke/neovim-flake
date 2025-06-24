{ buildNpmPackage }:

buildNpmPackage {
  pname = "css-variables-language-server";
  version = "2.7.1";
  src = ./.;
  npmDepsHash = "sha256-8y9WivfWGu07twu0W7nAnaK2GzbwP3/1BDfjrhltgaI=";
}
