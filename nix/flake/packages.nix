{ ... }:

{
  perSystem =
    { neovim, neovide, ... }:
    {
      overlayAttrs = {
        inherit neovim neovide;
      };

      packages = {
        default = neovim;
        inherit neovim neovide;
      };
    };
}
