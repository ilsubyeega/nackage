{
  description = "Personal packages for NixOS";
  nixConfig = {
    extra-substituters = [ "https://nackage.fmt.kr/" ];
    extra-trusted-public-keys = [ "nackage.fmt.kr-1:I/ietoUNvJap5XQ4MgqK7ntfOGKj6rT7frv33pNpEr0=" ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:YaLTeR/niri/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    xwayland-satellite = {
      url = "github:Supreeeme/xwayland-satellite/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
    };

  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      eachSystem =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }
          )
        );

      # Mark all packages as requiring "nackage" feature.
      # This is used for explict binary cache usage.
      markPackageAsNackage =
        pkg:
        pkg.overrideAttrs (
          final: old: {
            pname = "nackage-" + old.pname;
            requiredSystemFeatures = (old.requiredSystemFeatures or [ ]) ++ [ "nackage" ];
          }
        );
      markAllPackageAsNackage =
        pkgsAttrs: builtins.mapAttrs (_: value: markPackageAsNackage value) pkgsAttrs;
    in
    {
      packages = eachSystem (
        pkgs:
        with pkgs;
        let
          hostPlatform = stdenv.hostPlatform;
          list = import ./packages/default.nix {
            inherit pkgs inputs hostPlatform;
          };
        in
        (markAllPackageAsNackage list)
        // {
          all = markPackageAsNackage (
            (pkgs.linkFarm "all-packages" list).overrideAttrs (old: {
              # the linkFarm package does not set the package name properly.
              pname = "nackage-all-packages";
              name = "nackage-all-packages";
              description = "All Nackage packages in a single derivation";
            })
          );
        }
      );
    };
}
