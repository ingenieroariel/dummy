{ curl
, dbus
, fetchFromGitHub
, glib
, json-glib
, lib
, nix-update-script
, openssl
, pkg-config
, stdenv
, meson
, ninja
, util-linux
, libnl
, systemd
}:

stdenv.mkDerivation rec {
  pname = "rauc";
  version = "1.11.2";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-IWfYjn8CCgYK2hna59Awr5tzWnXCtR6c1XpV5fCiSE4=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ pkg-config meson ninja glib ];

  buildInputs = [ curl dbus glib json-glib openssl util-linux libnl systemd ];

  mesonFlags = [
    "--buildtype=release"
    (lib.mesonOption "systemdunitdir" "${placeholder "out"}/lib/systemd/system")
    (lib.mesonOption "dbusinterfacesdir" "${placeholder "out"}/share/dbus-1/interfaces")
    (lib.mesonOption "dbuspolicydir" "${placeholder "out"}/share/dbus-1/system.d")
    (lib.mesonOption "dbussystemservicedir" "${placeholder "out"}/share/dbus-1/system-services")
  ];

  meta = with lib; {
    description = "Safe and secure software updates for embedded Linux";
    homepage = "https://rauc.io";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ emantor ];
    platforms = with platforms; linux;
    mainProgram = "rauc";
  };
}