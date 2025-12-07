# nackage
custom packages for Nix. used for caching purpose.

## Usage
```nix
{ inputs, system, ... }: {
  environment.systemPackages = [
    inputs.nackage.packages.${system}.your-desired-package
  ];
}
```
