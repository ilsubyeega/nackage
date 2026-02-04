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
    nix-alien = {
      url = "github:thiagokokada/nix-alien/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane/master";
    #repo-wprs.url = "github:wayland-transpositor/wprs/master";
    #repo-wprs.flake = false;
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
    in
    {
      packages = eachSystem (
        pkgs:
        with pkgs;
        let
          hostPlatform = stdenv.hostPlatform;
          list = (
            import ./packages/default.nix {
              inherit pkgs inputs hostPlatform;
            }
          );
          nackage-list = lib.concatMapAttrs (name: value: {
            "nackage-${name}" = value.overrideAttrs (old: {
              pname = "nackage-" + old.pname;
              requiredSystemFeatures = (old.requiredSystemFeatures or [ ]) ++ [ "nackage" ];
            });
          }) list;
        in
        list
        // nackage-list
        // {
          nackage-all = (pkgs.linkFarm "all-packages" nackage-list).overrideAttrs (old: {
            # the linkFarm package does not set the package name properly.
            pname = "nackage-all-packages";
            name = "nackage-all-packages";
            description = "All Nackage packages in a single derivation";
          });
        }
      );
    };
}
