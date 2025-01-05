{
  description = "Hailo RT NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules = {
        hailo = import ./hailo.nix;
      };
  };
}
