{ ... }:

{
  perSystem =
    {
      pkgs,
      neovim,
      ...
    }:
    let
      inherit (pkgs) callPackage runCommandLocal luaPackages;

      repoRoot = ../../.;
      nvimRoot = repoRoot + "/nvim";
      testRoot = nvimRoot + "/tests";
      integrationTestRoot = testRoot + "/integration";
      integrationFixtureRoot = integrationTestRoot + "/fixtures";
      integrationSupportRoot = testRoot + "/support";

      hermeticTestEnv = callPackage ../tests/hermeticTestEnv.nix { };

      runIntegrationTest = callPackage ../tests/runIntegrationTest.nix {
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
          preflight = "dotnet build";
        };
    in
    {
      checks = {
        checkhealth = runCommandLocal "checkhealth" { } ''
          set -euo pipefail
          ${hermeticTestEnv { }}
          ${neovim}/bin/nvim --headless "+checkhealth" +qa | tee $out
        '';

        luacheck =
          runCommandLocal "luacheck"
            {
              nativeBuildInputs = [ luaPackages.luacheck ];
            }
            ''
              set -euo pipefail
              mkdir "$TMPDIR/src"
              cp -R ${repoRoot}/. "$TMPDIR/src"
              chmod -R u+w "$TMPDIR/src"
              cd "$TMPDIR/src"
              luacheck nvim
              touch $out
            '';

        test = runCommandLocal "test" { } ''
          set -euo pipefail
          ${hermeticTestEnv { }}
          cd ${repoRoot}
          ${neovim}/bin/nvim --headless -c "PlenaryBustedDirectory nvim/tests/ {minimal_init = 'nvim/tests/minimal_init.lua'}" | tee $out
        '';

        "lsp-integration-test-harness" = runIntegrationTest {
          name = "lsp-integration-test-harness";
          fixture = "smoke";
          openFile = "README.md";
          spec = "lsp_harness_smoke.lua";
        };

        "lsp-integration-lua-lua-ls" = runIntegrationTest {
          name = "lsp-integration-lua-lua-ls";
          fixture = "lua/basic";
          openFile = "main.lua";
          spec = "lsp_lua.lua";
        };

        "lsp-integration-nix-nixd" = runIntegrationTest {
          name = "lsp-integration-nix-nixd";
          fixture = "nix/basic";
          openFile = "default.nix";
          spec = "lsp_nix.lua";
        };

        "lsp-integration-bash-bashls" = runIntegrationTest {
          name = "lsp-integration-bash-bashls";
          fixture = "bash/basic";
          openFile = "script.sh";
          spec = "lsp_bash.lua";
        };

        "lsp-integration-rust-rust-analyzer" = runIntegrationTest {
          name = "lsp-integration-rust-rust-analyzer";
          fixture = "rust/basic";
          openFile = "src/main.rs";
          spec = "lsp_rust.lua";
          extraPath = [
            pkgs.cargo
            pkgs.rustc
          ];
        };

        "lsp-integration-go-gopls" = runIntegrationTest {
          name = "lsp-integration-go-gopls";
          fixture = "go/basic";
          openFile = "main.go";
          spec = "lsp_go.lua";
          extraPath = [ pkgs.go ];
        };

        "lsp-integration-typescript-ts-ls" = runIntegrationTest {
          name = "lsp-integration-typescript-ts-ls";
          fixture = "typescript/basic";
          openFile = "src/index.ts";
          spec = "lsp_typescript.lua";
        };

        "lsp-integration-dotnet-8-roslyn" = mkRoslynIntegrationTest {
          sdkMajor = "8";
          sdkPackage = pkgs.dotnet-sdk_8;
          fixture = "dotnet/roslyn-net8";
        };

        "lsp-integration-dotnet-9-roslyn" = mkRoslynIntegrationTest {
          sdkMajor = "9";
          sdkPackage = pkgs.dotnet-sdk_9;
          fixture = "dotnet/roslyn-net9";
        };

        "lsp-integration-dotnet-10-roslyn" = mkRoslynIntegrationTest {
          sdkMajor = "10";
          sdkPackage = pkgs.dotnet-sdk_10;
          fixture = "dotnet/roslyn-net10";
        };

        "lsp-integration-python-pyright" = runIntegrationTest {
          name = "lsp-integration-python-pyright";
          fixture = "python/basic";
          openFile = "main.py";
          spec = "lsp_python_pyright.lua";
        };

        "lsp-integration-python-ruff" = runIntegrationTest {
          name = "lsp-integration-python-ruff";
          fixture = "python/basic";
          openFile = "main.py";
          spec = "lsp_python_ruff.lua";
        };
      };
    };
}
