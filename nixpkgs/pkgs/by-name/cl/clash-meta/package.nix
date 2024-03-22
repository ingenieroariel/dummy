{ lib
, fetchFromGitHub
, buildGoModule
}:

buildGoModule rec {
  pname = "clash-meta";
  version = "1.18.1";

  src = fetchFromGitHub {
    owner = "MetaCubeX";
    repo = "mihomo";
    rev = "v${version}";
    hash = "sha256-ezOkDrpytZQdc+Txe4eUyuWY6oipn9jIrmu7aO8lNlQ=";
  };

  vendorHash = "sha256-tvPR5kAta4MlMTwjfxwVOacRr2nVpfalbN08mfxml64=";

  excludedPackages = [ "./test" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/metacubex/mihomo/constant.Version=${version}"
  ];

  tags = [
    "with_gvisor"
  ];

  # network required
  doCheck = false;

  postInstall = ''
    mv $out/bin/mihomo $out/bin/clash-meta
  '';

  meta = with lib; {
    description = "A rule-based tunnel in Go. Present named mihomo";
    homepage = "https://github.com/MetaCubeX/mihomo";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ oluceps ];
    mainProgram = "clash-meta";
  };
}
