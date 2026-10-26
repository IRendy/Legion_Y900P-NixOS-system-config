# OnAir — Nix translation of the Arch PKGBUILD (3.1.0).
#
# Dependency mapping notes:
#   * glibc, libgcc and libstdc++ come from stdenv, as usual in nixpkgs.
#   * codec2 and mbelib are not linked: OnAir dlopen()s them at run time.
#     The Arch package relies on them being in /usr/lib; here they are
#     symlinked into $out/lib/onair, one of the folders the loader searches
#     (docs/CODECS.md), so a plain `nix-build` needs no LD_LIBRARY_PATH.
#   * alsa-lib and libpulseaudio are dlopen()ed by the bundled miniaudio and
#     libGL is loaded through GLFW; they are put on the wrappers'
#     LD_LIBRARY_PATH because nothing links them into the ELF RPATH.
#   * soapyModules / extraRuntimeLibs cover the AUR optdepends that are
#     available in nixpkgs (soapyrtlsdr, soapyairspy, soapysdrplay and the
#     native radio libraries such as rtl-sdr). soapysdrplay needs the unfree
#     SDRplay API, so allowUnfree must be enabled to use it. onair-dra is not
#     packaged in nixpkgs: put its libonair_dra.so into
#     ~/.local/share/onair/codecs.
#   * hamlib is supported upstream and exists in nixpkgs, but the PKGBUILD
#     does not enable CAT rig control. Pass hamlib = pkgs.hamlib to turn it
#     on (CMake discovers it automatically).
#
# NixOS: the udev rules are installed in $out/lib/udev/rules.d, so activate
# them with
#     services.udev.packages = [ pkgs.onair ];
# The modprobe blacklists are installed in $out/etc/modprobe.d (the CMake
# install cannot write /etc inside the sandbox). NixOS ignores them; use the
# equivalent
#     boot.blacklistedKernelModules = [
#       "dvb_usb_rtl28xxu" "rtl2832" "rtl2830" "rtl2832_sdr" "e4000"
#       "sdr_msi3101" "msi001" "msi2500"
#     ];
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  cargo,
  rustc,
  makeWrapper,
  ffmpeg,
  glfw,
  hackrf,
  libusb1,
  soapysdr,
  # Optional Hamlib CAT rig control (the PKGBUILD leaves it disabled).
  hamlib ? null,
  libGL,
  alsa-lib,
  libpulseaudio,
  zenity,
  codec2,
  mbelib,
  # SoapySDR modules, e.g. [ soapyrtlsdr soapyairspy soapysdrplay ]; their
  # module directories are added to SOAPY_SDR_PLUGIN_PATH.
  soapyModules ? [ ],
  # Libraries OnAir dlopen()s itself, e.g. [ rtl-sdr airspy libbladeRF libiio libsecret ].
  extraRuntimeLibs ? [ ],
}:

let
  runtimeLibraryPath = lib.makeLibraryPath (
    [
      libGL
      alsa-lib
      libpulseaudio
    ]
    ++ extraRuntimeLibs
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "onair";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "adswill";
    repo = "OnAir";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZUgtdJoXVEj3Q5fV9r4xLMu/PowxkDuIjV6nqScv6Zc=";
  };

  # The PKGBUILD relaxes -Werror=format-security because the UI passes
  # non-literal format strings to ImGui::Text; drop the whole format
  # hardening instead (same as upstream's own nix package).
  hardeningDisable = [ "format" ];

  nativeBuildInputs = [
    cmake
    pkg-config
    cargo # the Rust workspace rust/ is mandatory (cmake/OnairRust.cmake)
    rustc
    makeWrapper
  ];

  buildInputs = [
    ffmpeg
    glfw
    hackrf
    libusb1
    soapysdr
    libGL
    alsa-lib
    libpulseaudio
  ]
  ++ lib.optional (hamlib != null) hamlib;

  postPatch = ''
    # cmake --install cannot write the absolute /etc/modprobe.d destination
    # inside the Nix sandbox; install those files below $out instead.
    substituteInPlace CMakeLists.txt \
      --replace-fail 'DESTINATION /etc/modprobe.d' 'DESTINATION etc/modprobe.d'

    # The fix-it hints point at install-udev-rules.sh, which only exists in
    # the source tree. Rewrite them for NixOS instead, string-based like the
    # PKGBUILD so upstream churn does not break the patch.
    if grep -rq 'install-udev-rules' app core --include='*.cpp' --include='*.h'; then
      while IFS= read -r f; do
        sed -i \
          -e "s|sudo ./install-udev-rules.sh   # in the OnAir folder; then unplug and replug the radio|# NixOS: add pkgs.onair to services.udev.packages; then unplug and replug the radio|g" \
          -e "s|Install OnAir's udev rules (install-udev-rules.sh), then unplug and replug the radio.|Enable OnAir's udev rules (services.udev.packages = [ pkgs.onair ] on NixOS), then unplug and replug the radio.|g" \
          -e "s|Install the udev rules (install-udev-rules.sh), then unplug and replug the radio.|Enable OnAir's udev rules (services.udev.packages = [ pkgs.onair ] on NixOS), then unplug and replug the radio.|g" \
          -e "s|Install the udev rules: run install-udev-rules.sh from the OnAir folder (the .deb package does it for you).|Enable the udev rules with services.udev.packages = [ pkgs.onair ] on NixOS.|g" \
          -e "s|Install the udev rules: run install-udev-rules.sh from the OnAir folder (the .deb does it).|Enable the udev rules with services.udev.packages = [ pkgs.onair ] on NixOS.|g" \
          -e "s|Or install OnAir's blacklist file (the .deb package does it).|Or add the drivers to boot.blacklistedKernelModules on NixOS.|g" \
          -e "s|Install OnAir's blacklist file (the .deb package does it), or run: sudo systemctl restart sdrplay|Add the drivers to boot.blacklistedKernelModules on NixOS, or run: sudo systemctl restart sdrplay|g" \
          -e "s|unplug and replug it after installing OnAir's blacklist file (the .deb does it), or restart the SDRplay API service|add the driver to boot.blacklistedKernelModules on NixOS, or restart the SDRplay API service|g" \
          -e "s|install OnAir's udev rules (the .deb does it, or run install-udev-rules.sh from the portable folder), then unplug and replug it|enable OnAir's udev rules (services.udev.packages = [ pkgs.onair ] on NixOS), then unplug and replug it|g" \
          -e "s|The udev rules (install-udev-rules.sh, done by the .deb) give it|The udev rules (services.udev.packages = [ pkgs.onair ] on NixOS) give it|g" \
          "$f"
      done < <(grep -rl 'install-udev-rules' app core --include='*.cpp' --include='*.h')

      if grep -rq 'install-udev-rules' app core --include='*.cpp' --include='*.h'; then
        echo 'onair: dangling install-udev-rules.sh references remain after rewrite;' >&2
        echo 'upstream changed the hint strings, the rewrite rules need a review' >&2
        exit 1
      fi
    else
      echo 'onair: no dangling udev-script hints found, nothing to rewrite'
    fi
  '';

  cmakeFlags = [
    (lib.cmakeBool "DECT2_BUILD_APP" true)
    (lib.cmakeBool "DECT2_BUILD_TESTS" true) # provides the dect2cli/dect2scan tools
    (lib.cmakeBool "DECT2_BUNDLE_CODEC2" false) # use the system codec2 instead
    (lib.cmakeBool "DECT2_CCACHE" false)
    (lib.cmakeBool "CMAKE_SKIP_INSTALL_ALL_DEPENDENCY" true)
    (lib.cmakeFeature "ONAIR_VERSION" finalAttrs.version)
  ];

  preConfigure = ''
    # cargo needs a writable home even for an offline build
    export CARGO_HOME=$TMPDIR/cargo
  '';

  # Only these targets are needed; `dect2` pulls in onair-plugin-host, the
  # example plug-ins and onair-server. Do not build the whole test suite.
  buildPhase = ''
    runHook preBuild
    cmake --build . --parallel $NIX_BUILD_CORES --target dect2 dect2cli dect2scan
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cmake --install .
    runHook postInstall
  '';

  postInstall = ''
    # dlopen()ed codecs: the loader looks in <bindir>/../lib/onair
    ln -s ${lib.getLib codec2}/lib/libcodec2.so* $out/lib/onair/
    ln -s ${lib.getLib mbelib}/lib/libmbe.so* $out/lib/onair/

    # The upstream unit hardcodes /usr/bin/onair-server.
    substituteInPlace $out/lib/systemd/system/onair-server.service \
      --replace-fail /usr/bin/onair-server $out/bin/onair-server
  '';

  postFixup = ''
    runtimeLibs="${runtimeLibraryPath}"

    soapyPath=""
    for m in ${lib.concatStringsSep " " (map toString soapyModules)}; do
      for d in "$m"/lib/SoapySDR/modules*; do
        if [ -d "$d" ]; then
          soapyPath="''${soapyPath:+$soapyPath:}$d"
        fi
      done
    done
    soapyArgs=()
    if [ -n "$soapyPath" ]; then
      soapyArgs=(--prefix SOAPY_SDR_PLUGIN_PATH : "$soapyPath")
    fi

    wrapProgram $out/bin/onair \
      --prefix LD_LIBRARY_PATH : "$runtimeLibs" \
      --suffix PATH : ${lib.makeBinPath [ zenity ]} \
      "''${soapyArgs[@]}"
    for prog in onair-cli onair-scan onair-server; do
      wrapProgram $out/bin/$prog \
        --prefix LD_LIBRARY_PATH : "$runtimeLibs" \
        "''${soapyArgs[@]}"
    done
  '';

  meta = {
    description = "SDR receiver for digital TV (DVB-T/T2, DVB-S/S2, ATSC), DAB+, FM, DRM, ADS-B, GNSS and DMR";
    homepage = "https://github.com/adswill/OnAir";
    license = lib.licenses.gpl3Plus; # REUSE.toml: GPL-3.0-or-later
    platforms = lib.platforms.linux;
    mainProgram = "onair";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
