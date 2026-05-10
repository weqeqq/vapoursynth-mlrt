{
  lib,
  buildPythonPackage,
  python,
  src,
  version,
  commonMeta,
  vapoursynth,
}:
buildPythonPackage {
  pname = "vsmlrt";
  inherit version src;
  format = "other";

  propagatedBuildInputs = [vapoursynth];

  dontConfigure = true;
  dontBuild = true;
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm644 scripts/vsmlrt.py "$out/${python.sitePackages}/vsmlrt.py"
    runHook postInstall
  '';

  pythonImportsCheck = [];

  meta =
    commonMeta
    // {
      description = "Python wrapper for vs-mlrt (Waifu2x, RIFE, RealESRGAN, etc.)";
    };
}
