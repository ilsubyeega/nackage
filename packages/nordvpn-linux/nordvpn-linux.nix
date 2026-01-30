{
  pkgs,
  ...
}@args:
let
  depsNordVpnLinux = (import ./deps.nix).nordvpn-linux args;
  libtelio = import ./libtelio.nix args;

in
pkgs.buildGoModule {
  pname = "nordvpn-linux";
  inherit (depsNordVpnLinux) src version vendorHash;

  nativeBuildInputs = with pkgs; [
    pkg-config
    breakpointHook
  ];
  buildInputs = with pkgs; [
    libxml2
    libidn2
    systemd
    libtelio
  ];

  checkFlags = [
    "-short"
    "-skip=TestTransports|TestH1Transport_RoundTrip|Test_validateHttpTransportsString|"
  ];
  
  # FIXME: currently test fails with FFI mismatch with libtelio; investigate later
  doCheck = false;
  
  meta = with pkgs.lib; {
    description = "NordVPN Client from git source";
    homepage = "https://github.com/NordSecurity/nordvpn-linux";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };

}
