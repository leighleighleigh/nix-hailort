{
  description = "Hailo RT NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules = {
      hailo = { config, pkgs, ... }: let
        debugSymbols = config.options.hailo.debugSymbols or false;
      in
        import ./hailo.nix { inherit config pkgs debugSymbols; };
    };
  };
}
