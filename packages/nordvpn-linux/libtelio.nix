{
  pkgs,
  inputs,
  ...
}@args:
let
  craneLib = inputs.crane.mkLib pkgs;
  deps = import ./deps.nix;
  depsLibtelio = deps.libtelio args;
  depsLltProto = deps.llt-proto args;

  lib = pkgs.lib;

  baseArgs = {
    pname = "libtelio";
    inherit (depsLibtelio) version src;
  };

  cargoVendorDir = craneLib.vendorCargoDeps (
    baseArgs
    // {
      overrideVendorGitCheckout =
        ps: drv:
        if lib.any (p: lib.hasPrefix "git+https://github.com/NordSecurity/llt-proto" p.source) ps then
          depsLltProto.overrideVendorGitCheckout drv
        else
          drv;
    }
  );

in
craneLib.buildPackage (
  baseArgs
  // {
    inherit cargoVendorDir;
    strictDeps = true;
    nativeBuildInputs = with pkgs; [
      pkg-config
      cmakeMinimal
      git
      protobuf
      ninja
      aws-lc
      rustPlatform.bindgenHook
    ];

    postPatch = ''
      # automatically fix scripts; (e.g #!/usr/bin/env bash -> #!/nix/store/.../bin/bash)
      patchShebangs .

      echo 'removing explicit target linker configuration at `.cargo/config.toml`'
      sed -i -e '/linker =/d' .cargo/config.toml
    '';

    cargoTestExtraArgs = builtins.concatStringsSep " " [
      # skip doctest
      "--lib --bins"
      "--"
      # these three: Direct entities should be available when "direct" feature is on
      "--skip test_default_features_when_direct_is_empty"
      "--skip test_default_features_when_provider_is_empty"
      "--skip test_enable_all_direct_features"
    ];

    # no clue what is this flag for, but it was introduced in upstream CI and if not set, it panics.
    env.BYPASS_LLT_SECRETS = "1";
    meta = with pkgs.lib; {
      description = "A Rust library intended to use for NordVPN softwares (nordvpn-linux)";
      homepage = "https://nordvpn.com";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  }
)
