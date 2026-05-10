{
  description = "VapourSynth ML filter runtimes (vs-mlrt) — CUDA / TensorRT backends";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    vs-mlrt-src = {
      url = "github:AmusementClub/vs-mlrt/v15.16";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    vs-mlrt-src,
    ...
  }: let
    version = "15.16";
    src = vs-mlrt-src;

    commonMeta = {
      homepage = "https://github.com/AmusementClub/vs-mlrt";
      license = nixpkgs.lib.licenses.gpl3Plus;
      platforms = ["x86_64-linux" "aarch64-linux"];
      maintainers = [];
    };
  in
    flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux"] (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };

      vapoursynth-vstrt = pkgs.callPackage ./pkgs/vstrt.nix {
        inherit src version commonMeta;
      };

      vapoursynth-vsort-cuda = pkgs.callPackage ./pkgs/vsort.nix {
        inherit src version commonMeta;
        enableCuda = true;
      };

      vsmlrt = pkgs.python3Packages.callPackage ./pkgs/vsmlrt-python.nix {
        inherit src version commonMeta;
      };
    in {
      packages = {
        inherit vapoursynth-vstrt vapoursynth-vsort-cuda vsmlrt;
      };

      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.cmake
          pkgs.ninja
          pkgs.pkg-config
          pkgs.vapoursynth
          pkgs.cudaPackages.cudatoolkit
          pkgs.cudaPackages.tensorrt
          pkgs.onnxruntime
          pkgs.onnx
          pkgs.protobuf
        ];
      };
    });
}
