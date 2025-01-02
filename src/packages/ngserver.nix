{ pkgs }:

let
  mkAngularLanguageServer =
    version: hash:
    pkgs.angular-language-server.overrideAttrs (oldAttrs: {
      version = version;
      src = pkgs.fetchurl {
        name = "angular-language-server-${version}.zip";
        url = "https://github.com/angular/vscode-ng-language-service/releases/download/v${version}/ng-template.vsix";
        hash = hash;
      };
    });

  v15 = mkAngularLanguageServer "15.2.1" "sha256-cvIP6vxFO2bu3LW7zWzn0iHQBXcdZlPv18+mi3QZxCE=";
  v16 = mkAngularLanguageServer "16.2.0" "sha256-tGaH6Kg4rpR5JMmLHqde4lmJ0Bo1mMgUrjW3fbZebqs=";
  v17 = mkAngularLanguageServer "17.3.2" "sha256-rqPGS9Fs+5QX94uW4Ttx7O8hlzo0g1aWFpKHsz1+7gg=";
  v18 = mkAngularLanguageServer "18.2.0" "sha256-rl04nqSSBMjZfPW8Y+UtFLFLDFd5FSxJs3S937mhDWE=";
  latest = pkgs.angular-language-server;
in

pkgs.writeShellApplication {
  name = "ngserver";
  runtimeInputs = [
    pkgs.fzf
    pkgs.jq
  ];
  text = ''
    function get_angular_version() {
      npm list @angular/core --json | jq -r '.dependencies."@angular/core".version' | cut -d. -f1
    }
    function get_server_for_version() {
      local version=$1

      case $version in
        15)
          echo "${v15}/bin/ngserver"
          ;;
        16)
          echo "${v16}/bin/ngserver"
          ;;
        17)
          echo "${v17}/bin/ngserver"
          ;;
        18)
          echo "${v18}/bin/ngserver"
          ;;
        *)
          echo "${latest}/bin/ngserver"
          ;;
      esac
    }

    angular_version=$(get_angular_version)
    server_path=$(get_server_for_version "$angular_version")
    exec "$server_path" "$@"
  '';
}
