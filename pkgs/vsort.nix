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
  onnx,
  onnxruntime,
  protobuf,
  cudaPackages,
  enableCuda ? true,
}:
stdenv.mkDerivation {
  pname = "vapoursynth-vsort${lib.optionalString enableCuda "-cuda"}";
  inherit version src;

  sourceRoot = "source/vsort";

  nativeBuildInputs =
    [
      cmake
      ninja
      pkg-config
    ]
    ++ lib.optionals enableCuda [
      cudaPackages.cuda_nvcc
    ];

  buildInputs =
    [
      vapoursynth
      onnx
      onnxruntime
      protobuf
    ]
    ++ lib.optionals enableCuda [
      cudaPackages.cuda_cudart
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
    "-DONNX_RUNTIME_API_DIRECTORY=${onnxruntime.dev}/include/onnxruntime"
    "-DONNX_RUNTIME_LIB_DIRECTORY=${onnxruntime}/lib"
    "-DCMAKE_INSTALL_LIBDIR=lib/vapoursynth"
    (lib.cmakeBool "ENABLE_CUDA" enableCuda)
  ];

  meta =
    commonMeta
    // {
      description = "VapourSynth ONNX Runtime backend (vsort)${lib.optionalString enableCuda " with CUDA"}";
    };
}
