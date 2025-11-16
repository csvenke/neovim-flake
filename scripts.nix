{
  writeShellApplication,
  curl,
  jq,
  nurl,
  sd,
  stylua,
  luaPackages,
}:

let
  update-vim-plugin = writeShellApplication {
    name = "update-vim-plugin";
    runtimeInputs = [
      curl
      jq
      nurl
      sd
    ];
    text = ''
      update_vim_plugin() {
        local owner="$1"
        local repo="$2"
        local branch="''${3:-main}"
        local package_file="''${4:-package.nix}"

        echo "Fetching latest commit from ''${owner}/''${repo}..."
        local latest_commit
        latest_commit=$(curl -s "https://api.github.com/repos/''${owner}/''${repo}/commits/''${branch}" | jq -r '.sha')

        if [ -z "$latest_commit" ] || [ "$latest_commit" = "null" ]; then
          echo "Error: Could not fetch latest commit"
          return 1
        fi

        echo "Latest commit: ''${latest_commit}"

        local current_version
        current_version=$(grep -oP 'version = "\K[^"]+' "$package_file" | head -1 || echo "unknown")
        echo "Current version: ''${current_version}"

        if [ "$current_version" = "$latest_commit" ]; then
          echo "Already up to date!"
          return 0
        fi

        echo "Fetching hash for new version..."
        local fetcher_output new_hash
        fetcher_output=$(nurl "https://github.com/''${owner}/''${repo}" "$latest_commit" 2>&1)
        new_hash=$(echo "$fetcher_output" | grep -oP 'hash = "\K[^"]+')

        if [ -z "$new_hash" ]; then
          echo "Error: Could not fetch hash"
          return 1
        fi

        echo "New hash: ''${new_hash}"

        echo "Updating ''${package_file}..."
        sd "version = \"[a-f0-9]{40}\";" "version = \"''${latest_commit}\";" "$package_file"
        sd "sha256 = \"[^\"]+\";" "sha256 = \"''${new_hash}\";" "$package_file"

        echo "✓ Updated ''${repo} from ''${current_version:0:7} to ''${latest_commit:0:7}"
        return 0
      }

      if [ $# -eq 0 ]; then
        echo "Usage: source <(update-vim-plugin) to load the function"
        echo "   or: update-vim-plugin <owner> <repo> [branch] [file]"
        exit 1
      else
        update_vim_plugin "$@"
      fi
    '';
  };
in

{
  format = writeShellApplication {
    name = "format";
    runtimeInputs = [
      stylua
    ];
    text = ''
      stylua --glob '**/*.lua' "$@" -- nvim/lua
    '';
  };

  lint = writeShellApplication {
    name = "lint";
    runtimeInputs = [
      luaPackages.luacheck
    ];
    text = ''
      luacheck nvim/lua
    '';
  };

  update = writeShellApplication {
    name = "update";
    runtimeInputs = [ update-vim-plugin ];
    text = ''
      update-vim-plugin "NotAShelf" "direnv.nvim" "main" "./overlays/vim-plugins/direnv-nvim/package.nix"
      update-vim-plugin "mistweaverco" "kulala.nvim" "main" "./overlays/vim-plugins/kulala-nvim/package.nix"
      update-vim-plugin "AlexvZyl" "nordic.nvim" "main" "./overlays/vim-plugins/nordic-nvim/package.nix"
      nix flake update
    '';
  };
}
