{
  description = "nixd integration fixture";

  outputs =
    { self }:
    {
      lib = import ./default.nix;
    };
}
