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

  outputs = { nixpkgs, ... }@inputs:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      }));
    in
    {
      packages = eachSystem (pkgs: let
        hostPlatform = pkgs.stdenv.hostPlatform;
        list = {
          #test = pkgs.callPackage ./packages/test/package.nix { };

          # Re-export for caching.
          inherit (inputs.niri.packages.${hostPlatform.system}) niri niri-debug;
          inherit (inputs.xwayland-satellite.packages.${hostPlatform.system}) xwayland-satellite;
        };
      in list // {
        all = pkgs.linkFarm "all-packages" list;
      });
    };
}
