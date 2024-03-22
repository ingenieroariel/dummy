{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchpatch
, pythonAtLeast

# build-system
, setuptools

# dependencies
, dnspython
, greenlet
, isPyPy
, six

# tests
, nose3
, iana-etc
, pytestCheckHook
, libredirect
}:

buildPythonPackage rec {
  pname = "eventlet";
  version = "0.33.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "eventlet";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-iSSEZgPkK7RrZfU11z7hUk+JbFsCPH/SD16e+/f6TFU=";
  };

  patches = [
    # Python 3.12 fixes:
    # - remove usage of distutils
    # - replace ssl.wrap_socket usage
    ./remove-distutils-usage.patch
    (fetchpatch {
      url = "https://src.fedoraproject.org/rpms/python-eventlet/raw/rawhide/f/python3.12.patch";
      hash = "sha256-MxzprFaVcV1uamjjTeIz+2gPvfPy+Y1QaA20znMdwoA=";
    })
    # fix tests running on kernel 6.6 or newer
    # https://github.com/eventlet/eventlet/pull/905
    (fetchpatch {
      url = "https://github.com/eventlet/eventlet/commit/413327b229c80a97e9c89c52f7714224942701b4.patch";
      hash = "sha256-rbYPd5cg3ElSYWYaZJrS7bb4nMJkTMO0ScvNnXRXzE0=";
    })
  ];

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    dnspython
    greenlet
    six
  ];

  nativeCheckInputs = [
    pytestCheckHook
    nose3
  ];

  # libredirect is not available on darwin
  # tests hang on pypy indefinitely
  # nose3 is incompatible with Python 3.12.
  doCheck = !stdenv.isDarwin && !isPyPy && !(pythonAtLeast "3.12");

  preCheck = lib.optionalString doCheck ''
    echo "nameserver 127.0.0.1" > resolv.conf
    export NIX_REDIRECTS=/etc/protocols=${iana-etc}/etc/protocols:/etc/resolv.conf=$(realpath resolv.conf)
    export LD_PRELOAD=${libredirect}/lib/libredirect.so

    export EVENTLET_IMPORT_VERSION_ONLY=0
  '';

  disabledTests = [
    # Tests requires network access
    "test_017_ssl_zeroreturnerror"
    "test_018b_http_10_keepalive_framing"
    "test_getaddrinfo"
    "test_hosts_no_network"
    "test_leakage_from_tracebacks"
    "test_patcher_existing_locks_locked"
    # broken with pyopenssl 22.0.0
    "test_sendall_timeout"
    # broken on aarch64 and when using march in gcc
    "test_fork_after_monkey_patch"
  ];

  disabledTestPaths = [
    # Tests are out-dated
    "tests/stdlib/test_asynchat.py"
    "tests/stdlib/test_asyncore.py"
    "tests/stdlib/test_ftplib.py"
    "tests/stdlib/test_httplib.py"
    "tests/stdlib/test_httpservers.py"
    "tests/stdlib/test_os.py"
    "tests/stdlib/test_queue.py"
    "tests/stdlib/test_select.py"
    "tests/stdlib/test_SimpleHTTPServer.py"
    "tests/stdlib/test_socket_ssl.py"
    "tests/stdlib/test_socket.py"
    "tests/stdlib/test_socketserver.py"
    "tests/stdlib/test_ssl.py"
    "tests/stdlib/test_subprocess.py"
    "tests/stdlib/test_thread__boundedsem.py"
    "tests/stdlib/test_thread.py"
    "tests/stdlib/test_threading_local.py"
    "tests/stdlib/test_threading.py"
    "tests/stdlib/test_timeout.py"
    "tests/stdlib/test_urllib.py"
    "tests/stdlib/test_urllib2_localnet.py"
    "tests/stdlib/test_urllib2.py"
  ];

  # unfortunately, it needs /etc/protocol to be present to not fail
  # pythonImportsCheck = [ "eventlet" ];

  meta = with lib; {
    changelog = "https://github.com/eventlet/eventlet/blob/v${version}/NEWS";
    description = "A concurrent networking library for Python";
    homepage = "https://github.com/eventlet/eventlet/";
    license = licenses.mit;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
