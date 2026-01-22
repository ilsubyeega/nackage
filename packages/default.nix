{
  pkgs,
  inputs,
  hostPlatform,
  ...
}@args:
{
  inherit (inputs.xwayland-satellite.packages.${hostPlatform.system}) xwayland-satellite;
  inherit (inputs.nix-alien.packages.${hostPlatform.system}) nix-alien;
  inherit (import ./nordvpn/default.nix args) nordvpn libtelio;
}
// (import ./niri/default.nix args)
