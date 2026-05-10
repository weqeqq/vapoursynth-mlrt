{
  lib,
  stdenv,
  src,
  version,
  commonMeta,
  cmake,
  ninja,
  pkg-config,
  vapoursynth,
  cudaPackages,
}:
stdenv.mkDerivation {
  pname = "vapoursynth-vstrt";
  inherit version src;

  sourceRoot = "source/vstrt";

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    cudaPackages.cuda_nvcc
  ];

  buildInputs = [
    vapoursynth
    cudaPackages.cuda_cudart
    cudaPackages.tensorrt
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'find_package(Git REQUIRED)' 'set(VCS_TAG "v${version}")' \
      --replace-fail 'execute_process(' 'if(FALSE)
    execute_process(' \
      --replace-fail 'string(STRIP ''${VCS_TAG} VCS_TAG)' 'endif()'
  '';

  cmakeFlags = [
    "-DVAPOURSYNTH_INCLUDE_DIRECTORY=${vapoursynth}/include/vapoursynth"
    "-DTENSORRT_HOME=${cudaPackages.tensorrt}"
    "-DUSE_NVINFER_PLUGIN=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib/vapoursynth"
  ];

  meta = commonMeta // {
    description = "VapourSynth TensorRT runtime (vstrt) for vs-mlrt";
  };
}
