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
