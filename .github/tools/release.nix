{ pkgs }:

pkgs.writeShellApplication {
  name = "release";
  runtimeInputs = [ pkgs.semantic-release ];
  text = ''
    semantic-release \
      --branch main \
      --plugins @semantic-release/github @semantic-release/commit-analyzer @semantic-release/release-notes-generator
  '';
}
