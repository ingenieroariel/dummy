{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, urllib3
, types-urllib3
}:

buildPythonPackage rec {
  pname = "types-requests";
  version = "2.31.0.20240310";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-iiAXHgiKD3iTqsSQpffzfp9T4U1rdixdVWI76gIu4G8=";
  };

  nativeBuildInputs = [
    setuptools
    urllib3
  ];

  propagatedBuildInputs = [
    types-urllib3
  ];

  # Module doesn't have tests
  doCheck = false;

  pythonImportsCheck = [
    "requests-stubs"
  ];

  meta = with lib; {
    description = "Typing stubs for requests";
    homepage = "https://github.com/python/typeshed";
    license = licenses.asl20;
    maintainers = with maintainers; [ fab ];
  };
}
