{
  wprs =
    { pkgs, ... }@args:
    let
      rev = "d76a07d248734d63e469c552fea7bfd227d96504";
      gitHash = "sha256-q1VwccdmIdM0Neh5vZliOo8F/UjPkn1cU/Hzt33GerY=";
      cargoHash = pkgs.lib.fakeHash;
    in
    {
      inherit rev cargoHash;
      src = pkgs.fetchFromGitHub {
        owner = "wayland-transpositor";
        repo = "wprs";
        rev = rev;
        hash = gitHash;
      };
    };
}
