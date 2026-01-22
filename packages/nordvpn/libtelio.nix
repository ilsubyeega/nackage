{
  pkgs,
  inputs,
  ...
}:
let
  craneLib = inputs.crane.mkLib pkgs;

  version = "c29f4ebe58973e237ed9792767bb60c6c72c02b1";
  src = pkgs.fetchFromGitHub {
    owner = "ilsubyeega";
    repo = "libtelio";
    rev = version;
    hash = "sha256-ZDzINJafqhweeHKxYbPIUWYtS7MJ9qIzsCa783yepqs=";
  };

  lib = pkgs.lib;

in
craneLib.buildPackage {
  pname = "libtelio";
  inherit version src;
  strictDeps = true;

  nativeBuildInputs = with pkgs; [
    pkg-config
    cmake
    rustPlatform.bindgenHook
    stdenv.cc
    breakpointHook
    bash
  ];

  buildInputs = with pkgs; [
    aws-lc
    llvmPackages.libclang
    protobuf
  ];

  # FIXME: patch and testing does both deps and main phase; not desirable and throws doctest..
  
  postPatch = ''
    # automatically fix scripts; (e.g #!/usr/bin/env bash -> #!/nix/store/.../bin/bash)
    patchShebangs .
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

  env = with pkgs; {
    LIBCLANG_PATH = "${lib.getLib llvmPackages.libclang.lib}/lib";
    PROTOC = "${protobuf}/bin/protoc";
    # what is this
    BYPASS_LLT_SECRETS = "1";
    # FIXME: This is not ideal; crane issue?
    CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER = "${pkgs.stdenv.cc.targetPrefix}cc";
  };

  meta = with pkgs.lib; {
    description = "A Library intended to use for NordVPN";
    homepage = "https://nordvpn.com";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
