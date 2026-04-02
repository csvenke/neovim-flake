{ inputs, ... }:

{
  perSystem =
    { system, ... }:
    let
      repoRoot = ../../.;
      nvimRoot = repoRoot + "/nvim";
      testRoot = nvimRoot + "/tests";
      integrationTestRoot = testRoot + "/integration";
      integrationFixtureRoot = integrationTestRoot + "/fixtures";
      integrationSupportRoot = testRoot + "/support";

      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          (import ../overlays/default.nix)
          inputs.nix-gen-luarc-json.overlays.default
        ];
      };
      plugins = pkgs.callPackage ../pkgs/plugins.nix { };
      runtimeDeps = pkgs.callPackage ../pkgs/runtimeDeps.nix { };
      neovim = pkgs.callPackage ../pkgs/neovim.nix {
        src = nvimRoot;
        inherit plugins runtimeDeps;
      };
      neovide = pkgs.neovide.overrideAttrs {
        inherit neovim;
      };
      hermeticTestEnv = pkgs.callPackage ../tests/hermeticTestEnv.nix { };
      runIntegrationTest = pkgs.callPackage ../tests/runIntegrationTest.nix {
        inherit neovim hermeticTestEnv;
        inherit integrationFixtureRoot;
        helperSrc = integrationSupportRoot;
        integrationSpecRoot = integrationTestRoot;
      };
      mkRoslynIntegrationTest =
        {
          sdkMajor,
          sdkPackage,
          fixture,
        }:
        runIntegrationTest {
          name = "lsp-integration-dotnet${sdkMajor}-roslyn";
          inherit fixture;
          openFile = "src/App/Program.cs";
          spec = "lsp_dotnet_roslyn.lua";
          extraPath = [ sdkPackage ];
          extraEnv = {
            DOTNET_ROOT = "${sdkPackage}";
            DOTNET_MULTILEVEL_LOOKUP = "0";
            INTEGRATION_TEST_DOTNET_SDK_MAJOR = sdkMajor;
          };
          preflight = ''
            dotnet_version="$(${pkgs.coreutils}/bin/timeout 30s dotnet --version 2>&1)" || {
              printf '%s\n' 'Roslyn integration preflight failed: dotnet SDK ${sdkMajor} is unavailable for the fixture workspace. Ensure the check injects pkgs.dotnet-sdk_${sdkMajor} via extraPath/extraEnv.' >&2
              printf '%s\n' "$dotnet_version" >&2
              exit 1
            }

            case "$dotnet_version" in
              ${sdkMajor}.*) ;;
              *)
                printf '%s\n' "Roslyn integration preflight failed: expected dotnet SDK ${sdkMajor}.x from global.json, got: $dotnet_version" >&2
                exit 1
                ;;
            esac
          '';
        };
    in
    {
      _module.args = {
        inherit
          hermeticTestEnv
          mkRoslynIntegrationTest
          neovide
          neovim
          pkgs
          plugins
          repoRoot
          runIntegrationTest
          testRoot
          integrationTestRoot
          integrationFixtureRoot
          ;
      };
    };
}
