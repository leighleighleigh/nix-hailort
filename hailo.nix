{ config, pkgs, debugSymbols ? false, ... }:

let
  protobuf = pkgs.fetchFromGitHub {
    owner = "protocolbuffers";
    repo = "protobuf";
    rev = "v21.12";
    sha256 = "09a4c9cr2958gdzz5i3ncmq95a0417kn96ch3w9lpvdmg8a0952m";
  };

  spdlog = pkgs.fetchFromGitHub {
    owner = "gabime";
    repo = "spdlog";
    rev = "22a169bc319ac06948e7ee0be6b9b0ac81386604";
    sha256 = "1b1b3zmbyjgqz5yfdgaasi55x03d37z7l2pasvgikx3mm1gabq5a";
  };

  benchmark = pkgs.fetchFromGitHub {
    owner = "google";
    repo = "benchmark";
    rev = "f91b6b42b1b9854772a90ae9501464a161707d1e";
    sha256 = "0mi8yzvk5zxvs3cxwg8nvbqj8dvsrfab4b8k5634nxjbk3f680hh";
  };

  catch2 = pkgs.fetchFromGitHub {
    owner = "catchorg";
    repo = "Catch2";
    rev = "c4e3767e265808590986d5db6ca1b5532a7f3d13";
    sha256 = "0cizwi5lj666xn9y0qckxf35m1kchjf2j2h1hb5ax4fx3qg7q5in";
  };

  cli11 = pkgs.fetchFromGitHub {
    owner = "hailo-ai";
    repo = "CLI11";
    rev = "ae78ac41cf225706e83f57da45117e3e90d4a5b4";
    sha256 = "1v7f52fqigj84vbbbnvy6a89a5dgzxnawjs5ggaas8n8rf1hysi8";
  };

  dotwriter = pkgs.fetchFromGitHub {
    owner = "hailo-ai";
    repo = "DotWriter";
    rev = "e5fa8f281adca10dd342b1d32e981499b8681daf";
    sha256 = "0aknjbznv1f0akkqr2v2572gp3liwjwx6k35qjcddywc1bf7dhnm";
  };

  eigen = pkgs.fetchFromGitLab {
    owner = "libeigen";
    repo = "eigen";
    rev = "3147391d946bb4b6c68edd901f2add6ac1f31f8c";
    sha256 = "0k1c4qnymwwvm68rv6s0cyk08xbw65ixvwqccsh36c2axcqk3znp";
  };

  json = pkgs.fetchFromGitHub {
    owner = "ArthurSonzogni";
    repo = "nlohmann_json_cmake_fetchcontent";
    rev = "391786c6c3abdd3eeb993a3154f1f2a4cfe137a0";
    sha256 = "0qhz4dgknc2iym8qbwfvcpsvqy6057vm144syqykg04vbb67q3g4";
  };

  pybind11 = pkgs.fetchFromGitHub {
    owner = "pybind";
    repo = "pybind11";
    rev = "80dc998efced8ceb2be59756668a7e90e8bef917";
    sha256 = "0igpr3k52a033z2jdiirw84vyw1prmkz8j3q24k33nynybyv9m7l";
  };

  readerwriterqueue = pkgs.fetchFromGitHub {
    owner = "cameron314";
    repo = "readerwriterqueue";
    rev = "435e36540e306cac40fcfeab8cc0a22d48464509";
    sha256 = "0sh3rgj0mkw566ca6srvk4b8y2ca1y0rsa3bpcif62kdb3dx7hbl";
  };

  hailort = pkgs.stdenv.mkDerivation rec {
    pname = "hailort";
    version = "4.18.0";

    src = pkgs.fetchFromGitHub {
      owner = "hailo-ai";
      repo = "hailort";
      rev = "v${version}";
      sha256 = "0hc16i7sydjcf4fv38rp6vsd36xyp1nc9bhcc350976diqb5c00q";
    };

    nativeBuildInputs = [ pkgs.cmake pkgs.git pkgs.gcc pkgs.bash ];
    dontUseCmakeConfigure = true;

    buildInputs = [ protobuf spdlog benchmark catch2 cli11 dotwriter eigen json pybind11 readerwriterqueue ];

    patches = [
        ./fix-protobuf.patch
        ./fix-bash.patch
        ./fix-hrpc.patch
        ./fix-cli11.patch
        ./fix-dotwriter.patch
        ./fix-eigen.patch
        ./fix-json.patch
        ./fix-pybind11.patch
        ./fix-readwriter.patch
        ./fix-spdlog.patch
    ];

    buildPhase = ''
      # Create the external directories and copy the necessary files
      mkdir -p hailort/external/protobuf-src
      cp -r ${protobuf}/* hailort/external/protobuf-src

      mkdir -p hailort/external/spdlog-src
      cp -r ${spdlog}/* hailort/external/spdlog-src

      mkdir -p hailort/external/benchmark-src
      cp -r ${benchmark}/* hailort/external/benchmark-src

      mkdir -p hailort/external/catch2-src
      cp -r ${catch2}/* hailort/external/catch2-src

      mkdir -p hailort/external/cli11-src
      cp -r ${cli11}/* hailort/external/cli11-src

      mkdir -p hailort/external/dotwriter-src
      cp -r ${dotwriter}/* hailort/external/dotwriter-src

      mkdir -p hailort/external/eigen-src
      cp -r ${eigen}/* hailort/external/eigen-src

      mkdir -p hailort/external/json-src
      cp -r ${json}/* hailort/external/json-src

      mkdir -p hailort/external/pybind11-src
      cp -r ${pybind11}/* hailort/external/pybind11-src

      mkdir -p hailort/external/readerwriterqueue-src
      cp -r ${readerwriterqueue}/* hailort/external/readerwriterqueue-src

      # Configure and build the project
      cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=${if debugSymbols then "Debug" else "Release"} -DCMAKE_SKIP_BUILD_RPATH=ON
      cmake --build build --config ${if debugSymbols then "Debug" else "Release"}
    '';

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/lib

      cp build/hailort/hailortcli/hailortcli $out/bin/
      cp build/hailort/libhailort/src/libhailort.so* $out/lib/
    '';

    meta = with pkgs.lib; {
      description = "HailoRT CLI and library";
      license = licenses.mit;
      platforms = platforms.linux;
      homepage = "https://github.com/hailo-ai/hailort";
    };
  };

in {
  options = {
    hailo.debugSymbols = mkOption {
      type = types.bool;
      default = false;
      description = "Build HailoRT with debug symbols.";
    };
  };

  environment.systemPackages = [ hailort ];
  services.udev.extraRules = ''
      #Change mode rules for Hailo's PCIe driver
      SUBSYSTEM=="hailo_chardev", MODE="0666"
  '';
}
