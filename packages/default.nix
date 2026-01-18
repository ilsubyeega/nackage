{
  pkgs,
  inputs,
  hostPlatform,
  ...
}@args:
{
  inherit (inputs.xwayland-satellite.packages.${hostPlatform.system}) xwayland-satellite;
  inherit (inputs.nix-alien.packages.${hostPlatform.system}) nix-alien;
}
// (import ./niri/default.nix args)
