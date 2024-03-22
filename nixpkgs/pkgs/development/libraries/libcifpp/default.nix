{ lib
, stdenv
, boost
, cmake
, fetchFromGitHub
, fetchpatch
, eigen
, zlib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcifpp";
  version = "7.0.1";

  src = fetchFromGitHub {
    owner = "PDB-REDO";
    repo = "libcifpp";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-13jJH7YFlnb9hltCo/3kygPkXoE3ZZwZkG/ezbOxE2w=";
  };

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    # disable network access
    "-DCIFPP_DOWNLOAD_CCD=OFF"
  ];

  buildInputs = [
    boost
    eigen
    zlib
  ];

  meta = with lib; {
    description = "Manipulate mmCIF and PDB files";
    homepage = "https://github.com/PDB-REDO/libcifpp";
    changelog = "https://github.com/PDB-REDO/libcifpp/releases/tag/${finalAttrs.src.rev}";
    license = licenses.bsd2;
    maintainers = with maintainers; [ natsukium ];
    platforms = platforms.unix;
  };
})