# neovim flake

<p align="center">
    <img src=".github/assets/neovim-screenshot.png" />
</p>

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
