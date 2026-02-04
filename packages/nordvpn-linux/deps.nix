{
  nordvpn-linux =
    { pkgs, ... }:
    let
      # was going to use stable tag but rolling release of libtelio blocks that
      version = "df462a9ab13e79556c886d06d90b0fbe318c0807";
      hash = "sha256-nDL9qZHGPT51Pk5cla4ANKmY27TYfbhcqAAs3RZwei0=";
      vendorHash = "sha256-oXSl3QuW8DN8N5WezQwIj1KjIXBMZWOb2vY+ct5AOYo=";
    in
    {
      src = pkgs.fetchFromGitHub {
        owner = "NordSecurity";
        repo = "nordvpn-linux";
        rev = version;
        inherit hash;
      };
      inherit version vendorHash;
    };

  libtelio =
    { pkgs, ... }:
    let
      rev = "1919ba268edcca5ea30e0f7ca0e91ccc1fff006f";
      hash = "sha256-JYjtj3u6IDeq3lO9HVqGq8pAiiqu6HBF0dBgO1cnuUA=";
    in
    {
      src = pkgs.fetchFromGitHub {
        owner = "NordSecurity";
        repo = "libtelio";
        inherit rev hash;
      };
      version = rev;
    };

  # ltt-proto is not sandbox friendly due to git subdirectory usage for proto files.
  # We patch it here to move files to root dir, to vendor-friendly dir layout.
  # See: https://github.com/rust-lang/cargo/issues/16537
  llt-proto =
    { ... }:
    {
      # downloadCargoPackageFromGit :: set -> drv
      overrideVendorGitCheckout =
        drv:
        drv.overrideAttrs (old: {
          postPatch = ''
            # move `./rust/llt-proto` to `./`
            # concern: .gitignore not included in moving phase, but we don't need it anyway
            mv rust/llt-proto/* .
            rm -r rust

            # patch the build script to use root dir path for proto files
            # "../../ens" to "./ens"
            substituteInPlace build.rs \
                --replace-fail '../../ens' './ens'
          '';
        });
    };
}
