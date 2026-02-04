# Violently copied from
# https://github.com/NixOS/nixpkgs/blob/e576e3c9cf9bad747afcddd9e34f51d18c855b4e/pkgs/by-name/wp/wprs/package.nix
{
  inputs,
  pkgs,
  ...
}@args:
let
  craneLib = inputs.crane.mkLib pkgs;
  src = inputs.repo-wprs;
in
craneLib.buildPackage rec {
  pname = "wprs";
  version = src.shortRev or src.rev or "unknown";
  inherit src;

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];
  buildInputs = with pkgs; [
    libxkbcommon
    (python3.withPackages (pp: with pp; [ psutil ]))
  ];
  RUSTFLAGS = "-C target-feature=+avx2";
  postInstall = ''
    # Install wprs(python script) to root
    cp ${src}/wprs $out/bin/wprs
  '';

  meta = {
    description = "Rootless remote desktop access for remote wayland sessions";
    license = pkgs.lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    homepage = "https://github.com/wayland-transpositor/wprs";
    mainProgram = "wprs";
  };
}
