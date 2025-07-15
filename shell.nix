{pkgs ? import <nixpkgs> {}}:
let
    hailort = pkgs.callPackage ./hailort.nix {};
in
pkgs.mkShell rec {
  name = "uv-hailo";

  buildInputs = [ hailort ] ++ (with pkgs; [
    glib
    zlib

    libGL
    libGLU
    libxkbcommon
    stdenv.cc.cc
    gnumake

    # needed by hailomz
    graphviz
    protobuf

    # python  package management
    uv

    # needed beceuse this only works as a nix-shell --pure instantiation for some reason.
    curl
    cacert
    openssl
    vim
    git
  ]);

  shellHook = ''
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath buildInputs}";
  '';
}
