{ lib
, stdenv
, fetchFromGitHub
, SDL2
, callPackage
, cmake
, espeak-ng
, ffmpeg
, file
, freetype
, glib
, gumbo
, harfbuzz
, jbig2dec
, leptonica
, libGL
, libX11
, libXau
, libXcomposite
, libXdmcp
, libXfixes
, libdrm
, libffi
, libjpeg
, libusb1
, libuvc
, libvlc
, libvncserver
, libxcb
, libxkbcommon
, makeWrapper
, mesa
, mupdf
, openal
, openjpeg
, pcre2
, pkg-config
, ruby
, sqlite
, tesseract
, valgrind
, wayland
, wayland-protocols
, xcbutil
, xcbutilwm
, xz
, buildManPages ? true
, useBuiltinLua ? true
, useEspeak ? !stdenv.isDarwin
, useStaticLibuvc ? true
, useStaticOpenAL ? true
, useStaticSqlite ? true
, useTracy ? true
}:

let
  allSources = {
    letoram-arcan = {
      pname = "arcan";
      version = "0.6.2.1-unstable-2023-11-18";
      src = fetchFromGitHub {
        owner = "letoram";
        repo = "arcan";

        rev = "3b2516000d59398249ee029bfaaeb66cfff04891";
        hash = "sha256-OuCIF2Pb8o3HdNwiiphTRTzmVpqoPH4QgLtFO+SeJjU=";

        # Works!
        #rev = "0c2cd29c73c774ba04b26b8afe475e96a3240439";
        #hash = "sha256-dqQXYp1S4eDB3/Z+h2XIdFTlOIB8tkTUcqLdALU4nBA=";
        # March 7 does not work
        #rev = "105b6f02c31a7f6bdfcb37282c85b9f75414a629";
        #hash = "sha256-DSxHIhfzBot2lgqQEpUOQrY17ZIhVqtEBVhEVv84XzA=";
        
        # March 8 does not work
        #rev = "cb72ac6bba5304749b688af94b265b23cc54a216";
        #hash = "sha256-YHycWq1+M9BT+5797I3uCbELl2POndiXoqKZroB4Bvs=";
        
        # March 1st works
        #rev= "d188e3fb416866085862de302afcac62dcdcf240";

        #hash = "sha256-e2+GgrcWeHU72Wpp01c+gJf52yBqJWAb20W9R4Ej7Rc=";
        # Feb 24 works
        #rev = "440eefd6fb34624783b8594d7e8a28251e286cb8";
        
        #hash = "sha256-1ici3b1p1xuKjm1ShIg/edSH0W0EQs8ghcwvGGKeVBE=";
        #Jan 16 works
        #rev = "e1cc5da7cc4b0e93958428635d395ee6cdccf463";
        #hash = "sha256-KZXAABMbMgdNOPzDOwHp8icniWyBhcmW6O667z1nhLY=";
#        rev = "0950ee236f96a555729498d0fdf91c16901037f5";
#        hash = "sha256-TxadRlidy4KRaQ4HunPO6ISJqm6JwnMRM8y6dX6vqJ4=";
      };
    };
    letoram-openal-src = fetchFromGitHub {
      owner = "letoram";
      repo = "openal";
      rev = "81e1b364339b6aa2b183f39fc16c55eb5857e97a";
      hash = "sha256-X3C3TDZPiOhdZdpApC4h4KeBiWFMxkFsmE3gQ1Rz420=";
    };
    libuvc-src = fetchFromGitHub {
      owner = "libuvc";
      repo = "libuvc";
      rev = "68d07a00e11d1944e27b7295ee69673239c00b4b";
      hash = "sha256-IdV18mnPTDBODpS1BXl4ulkFyf1PU2ZmuVGNOIdQwzE=";
    };
    luajit-src = fetchFromGitHub {
      owner = "LuaJIT";
      repo = "LuaJIT";
      rev = "656ecbcf8f669feb94e0d0ec4b4f59190bcd2e48";
      hash = "sha256-/gGQzHgYuWGqGjgpEl18Rbh3Sx2VP+zLlx4N9/hbYLc=";
    };
    tracy-src = fetchFromGitHub {
      owner = "wolfpld";
      repo = "tracy";
      rev = "93537dff336e0796b01262e8271e4d63bf39f195";
      hash = "sha256-FNB2zTbwk8hMNmhofz9GMts7dvH9phBRVIdgVjRcyQM=";
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit (allSources.letoram-arcan) pname version src;

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
  ] ++ lib.optionals buildManPages [
    ruby
  ];

  buildInputs = [
    SDL2
    ffmpeg
    file
    freetype
    glib
    gumbo
    harfbuzz
    jbig2dec
    leptonica
    libGL
    libX11
    libXau
    libXcomposite
    libXdmcp
    libXfixes
    libdrm
    libffi
    libjpeg
    libusb1
    libuvc
    libvlc
    libvncserver
    libxcb
    libxkbcommon
    mesa
    mupdf
    openal
    openjpeg
    pcre2
    sqlite
    tesseract
    valgrind
    wayland
    wayland-protocols
    xcbutil
    xcbutilwm
    xz
  ]
  ++ lib.optionals useEspeak [
    espeak-ng
  ];

  # Emulate external/git/clone.sh
  postUnpack = let
    inherit (allSources)
      letoram-openal-src libuvc-src luajit-src tracy-src;
    prepareSource = flag: source: destination:
      lib.optionalString flag ''
        cp -va ${source}/ ${destination}
        chmod --recursive 744 ${destination}
      '';
  in
    ''
      pushd $sourceRoot/external/git/
    ''
    + prepareSource useStaticOpenAL letoram-openal-src "openal"
    + prepareSource useStaticLibuvc libuvc-src "libuvc"
    + prepareSource useBuiltinLua luajit-src "luajit"
    + prepareSource useTracy tracy-src "tracy"
    + ''
      popd
    '';

  postPatch = ''
    substituteInPlace ./src/platform/posix/paths.c \
      --replace "/usr/bin" "$out/bin" \
      --replace "/usr/share" "$out/share"
    substituteInPlace ./src/CMakeLists.txt \
      --replace "SETUID" "# SETUID"
  '';

  # INFO: Arcan build scripts require the manpages to be generated *before* the
  # `configure` phase
  preConfigure = lib.optionalString buildManPages ''
    pushd doc
    ruby docgen.rb mangen
    popd
  '';

  cmakeFlags = [
    # The upstream project recommends tagging the distribution
    (lib.cmakeFeature "DISTR_TAG" "Nixpkgs")
    (lib.cmakeFeature "ENGINE_BUILDTAG" finalAttrs.src.rev)
    (lib.cmakeFeature "BUILD_PRESET" "everything")
    (lib.cmakeBool "BUILTIN_LUA" useBuiltinLua)
    (lib.cmakeBool "DISABLE_JIT" useBuiltinLua)
    (lib.cmakeBool "STATIC_LIBUVC" useStaticLibuvc)
    (lib.cmakeBool "STATIC_SQLite3" useStaticSqlite)
    (lib.cmakeBool "ENABLE_TRACY" useTracy)
    "../src"
  ];

  hardeningDisable = [
    "format"
  ];

  passthru = {
    wrapper = callPackage ./wrapper.nix { };
  };

  meta = {
    homepage = "https://arcan-fe.com/";
    description = "Combined Display Server, Multimedia Framework, Game Engine";
    longDescription = ''
      Arcan is a portable and fast self-sufficient multimedia engine for
      advanced visualization and analysis work in a wide range of applications
      e.g. game development, real-time streaming video, monitoring and
      surveillance, up to and including desktop compositors and window managers.
    '';
    license = with lib.licenses; [ bsd3 gpl2Plus lgpl2Plus ];
    maintainers = with lib.maintainers; [ AndersonTorres ];
    platforms = lib.platforms.unix;
  };
})
