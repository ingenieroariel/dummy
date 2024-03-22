{ stdenv
, lib
, buildPythonPackage
, fetchFromGitHub
, appdirs
, dungeon-eos
, explorerscript
, ndspy
, pillow
, setuptools
, skytemple-rust
, tilequant
, pyyaml
, pmdsky-debug-py
, range-typed-integers
, importlib-resources
, typing-extensions
, pythonOlder
, # optional dependancies for SpriteCollab
  aiohttp
, lru-dict
, graphql-core
, gql
, armips
  # tests
, pytestCheckHook
, parameterized
, xmldiff
}:

buildPythonPackage rec {
  pname = "skytemple-files";
  version = "1.6.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "SkyTemple";
    repo = pname;
    rev = version;
    hash = "sha256-OkokbVD8j+Sgypj25demzSZdiAEf8TJrnl0QRIM2HsI=";
  };

  postPatch = ''
    substituteInPlace skytemple_files/patch/arm_patcher.py skytemple_files/data/data_cd/armips_importer.py \
      --replace "exec_name = os.getenv(\"SKYTEMPLE_ARMIPS_EXEC\", f\"{prefix}armips\")" "exec_name = \"${armips}/bin/armips\""
  '';

  buildInputs = [ armips ];

  propagatedBuildInputs = [
    appdirs
    dungeon-eos
    explorerscript
    ndspy
    pillow
    setuptools
    skytemple-rust
    tilequant
    pyyaml
    pmdsky-debug-py
    range-typed-integers
  ] ++ lib.optionals (pythonOlder "3.9") [
    importlib-resources
    typing-extensions
  ];

  passthru.optional-dependencies = {
    spritecollab = [
      aiohttp
      gql
      graphql-core
      lru-dict
    ] ++ gql.optional-dependencies.aiohttp;
  };

  checkInputs = [ pytestCheckHook parameterized xmldiff ] ++ passthru.optional-dependencies.spritecollab;
  pytestFlagsArray = [ "test/" ];
  disabledTestPaths = [
    "test/skytemple_files_test/common/spritecollab/sc_online_test.py"
    "test/skytemple_files_test/compression_container/atupx/atupx_test.py" # Particularly long test
  ];

  pythonImportsCheck = [ "skytemple_files" ];

  meta = with lib; {
    homepage = "https://github.com/SkyTemple/skytemple-files";
    description = "Python library to edit the ROM of Pokémon Mystery Dungeon Explorers of Sky";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ xfix marius851000 ];
    broken = stdenv.isDarwin; # pyobjc is missing
  };
}
