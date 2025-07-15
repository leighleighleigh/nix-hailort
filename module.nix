{ config, pkgs, lib, ...  ? import <nixpkgs> {}}:
let
    hailort = pkgs.callPackage ./hailort.nix {};
in {
  environment.systemPackages = [ hailort ];
  services.udev.extraRules = ''
      #Change mode rules for Hailo's PCIe driver
      SUBSYSTEM=="hailo_chardev", MODE="0666"
  '';
}
