{ lib
, fetchFromGitHub
, gitUpdater
, icu
, libkiwix
, meson
, ninja
, pkg-config
, stdenv
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kiwix-tools";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "kiwix";
    repo = "kiwix-tools";
    rev = finalAttrs.version;
    hash = "sha256-+th86lMAuCcmWj06yQoZ1L7rLZKqNvuTrV+Rra2km44=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    icu
    libkiwix
  ];

  passthru.updateScript = gitUpdater { };

  meta = with lib; {
    description = "Command line Kiwix tools: kiwix-serve, kiwix-manage, ...";
    homepage = "https://kiwix.org";
    changelog = "https://github.com/kiwix/kiwix-tools/releases/tag/${finalAttrs.version}";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ colinsane ];
  };
})
