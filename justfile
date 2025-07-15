build:
    #!/usr/bin/env bash
    nix-build -E '(import <nixpkgs> { }).callPackage ./hailort.nix { }'
