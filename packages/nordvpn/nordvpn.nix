{
  pkgs,
  inputs,
  hostPlatform,
  ...
}@args:
let
  libtelio = import ./libtelio.nix args;
  version = "4.3.1";

in
pkgs.buildGoModule {
  pname = "nordvpn";
  inherit version;
  src = pkgs.fetchFromGitHub {
    owner = "NordSecurity";
    repo = "nordvpn-linux";
    rev = version;
    hash = "sha256-o9+9IiXV2CS/Zj3bDg8EJn/UidwA6Fwn4ySFbwyCp60=";
  };

  vendorHash = "sha256-outOvVAu76Pa9lQbiXQP2wA2cee3Ofq41SwfL6JEKs0=";

  nativeBuildInputs = with pkgs; [
    pkg-config
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

  #preBuild = ''
  #  # remove the test which requires real network
  #  rm cmd/daemon/transports_test.go
  #'';

  postInstall = ''
    ls -al .
  '';

  meta = with pkgs.lib; {
    description = "NordVPN Client from git source";
    homepage = "https://github.com/NordSecurity/nordvpn-linux";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };

}
