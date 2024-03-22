{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
, pythonOlder
, requests
, setuptools
}:

buildPythonPackage rec {
  pname = "tencentcloud-sdk-python";
  version = "3.0.1102";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "TencentCloud";
    repo = "tencentcloud-sdk-python";
    rev = "refs/tags/${version}";
    hash = "sha256-VEYFNu8z/PVn+CcQzRdKtUw+JkKzxSIS6t6NMEaNNDc=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    requests
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "tencentcloud"
  ];

  pytestFlagsArray = [
    # Other tests require credentials
    "tests/unit/test_deserialize_warning.py"
    "tests/unit/test_import.py"
    "tests/unit/test_serialization.py"
  ];

  meta = with lib; {
    description = "Tencent Cloud API 3.0 SDK for Python";
    homepage = "https://github.com/TencentCloud/tencentcloud-sdk-python";
    changelog = "https://github.com/TencentCloud/tencentcloud-sdk-python/blob/${version}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ fab ];
  };
}