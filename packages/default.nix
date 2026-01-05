{
  pkgs,
  inputs,
  hostPlatform,
  ...
}@args:
{
  inherit (inputs.xwayland-satellite.packages.${hostPlatform.system}) xwayland-satellite;
  inherit (inputs.wayland-proxy.packages.${hostPlatform.system}) wayland-proxy;
}
// (import ./niri/default.nix args)
