{ lib
, buildPythonPackage
, fetchFromGitHub
, beautifulsoup4
, extruct
, language-tags
, regex
, requests
, pytestCheckHook
, responses
, setuptools
, pythonOlder
}:

buildPythonPackage rec {
  pname = "recipe-scrapers";
  version = "14.55.0";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "hhursev";
    repo = "recipe-scrapers";
    rev = "refs/tags/${version}";
    hash = "sha256-HjR4Lwlcrpeqv6BXI+aYCL9e7ZTaTa522z0lSW03wW0=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    beautifulsoup4
    extruct
    language-tags
    regex
    requests
  ];

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  disabledTests = [
    # Fixture is broken
    "test_instructions"
  ];

  pythonImportsCheck = [
    "recipe_scrapers"
  ];

  meta = with lib; {
    description = "Python package for scraping recipes data";
    homepage = "https://github.com/hhursev/recipe-scrapers";
    changelog = "https://github.com/hhursev/recipe-scrapers/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ ambroisie ];
  };
}