{
  pkgs,
  inputs,
  hostPlatform,
  ...
}:
let
  overrideNiri =
    niri:
    niri.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ./0001-Save-screenshot-to-disk-even-Ctrl-C-is-pressed.patch
      ];
    });

in
builtins.mapAttrs (_: package: overrideNiri package) {
  inherit (inputs.niri.packages.${hostPlatform.system}) niri niri-debug;
}
