# neovim flake

## Requirements

- [nix](https://nixos.org/download)

## Usage

```bash
nix run github:csvenke/neovim-flake
```

Without flakes enabled

```bash
nix run github:csvenke/neovim-flake --extra-experimental-features 'nix-command flakes'
```

## Development

- `nix fmt` applies repo formatting through treefmt (`nix develop` also exposes `treefmt` directly).
- `nix build .#checks.x86_64-linux.treefmt` runs the formatting check used by `nix flake check -L`.
- `nix build .#checks.x86_64-linux.codequality` runs `luacheck` as the lint check.
- `nix flake check -L` remains the full validation entrypoint and now runs formatting once via `checks.treefmt` plus the separate lint/test derivations.
