{
  pkgs,
  inputs,
  hostPlatform,
  ...
}:
{
  # re-export for binary cache.
  inherit (inputs.xwayland-satellite.packages.${hostPlatform.system}) xwayland-satellite;
}
