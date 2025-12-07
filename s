nix eval --raw .#niri-debug
nix build --dry-run .#niri-debug
nix search --json . ^