{
  nordvpn-linux =
    { pkgs, ... }:
    let
      # was going to use stable tag but rolling release of libtelio blocks that
      version = "1d4d411470ceff24b2c87397591efa8c1404fd3d";
      hash = "sha256-5Y5NmQ6xleRILWoImCspWyhTY3f9uIqzaMOdbAodUVo=";
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
      rev = "6be3ea355994dfb221ece467ad09190559dcdf0f";
      hash = "sha256-4bNJGtQtgOeHNNdZ617xSF/f7pKZmqBgmeXsT4f5ZhQ=";
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
