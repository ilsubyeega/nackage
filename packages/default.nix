{
  pkgs,
  inputs,
  hostPlatform,
  ...
}@args:
{
  inherit (inputs.xwayland-satellite.packages.${hostPlatform.system}) xwayland-satellite;
  inherit (inputs.nix-alien.packages.${hostPlatform.system}) nix-alien;
  inherit (import ./nordvpn-linux/default.nix args) nordvpn-linux libtelio;
  inherit (import ./niri/default.nix args) niri niri-debug;
  inherit (import ./wprs/default.nix args) wprs;
}
