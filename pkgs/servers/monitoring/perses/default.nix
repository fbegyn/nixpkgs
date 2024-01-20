{ stdenv
, lib
, go
, buildGoModule
, fetchFromGitHub
, fetchurl
, nixosTests
, nodejs
, git
, turbo
, jq
}:

let
  version = "0.43.0";
in
buildGoModule rec {
  pname = "perses";
  inherit version;

  outputs = [ "out" "doc" "cli" ];

  src = fetchFromGitHub {
    owner = "perses";
    repo = "perses";
    rev = "v${version}";
    hash = "sha256-gRPLa9qdvtIxy8Bt5yofUzFoSRgz6HH8Aved6XGQ4xQ=";
  };

  vendorHash = "sha256-mwVBF2LBM4pLgCxgGCgwwuaN8yyr9hrna/IjDciOan4=";

  excludedPackages = [ ];

  nativeBuildInputs = [
    nodejs
    turbo
    git
    jq
  ];

  postPatch = ''
  '';

  preBuild = ''
  '';

  buildPhase = ''
    make build
  '';

  tags = [ ];

  ldflags =
    let
      t = "github.com/perses/perses";
    in
    [
      "-s"
      "-w"
      "-X ${t}.Version=${version}"
      "-X ${t}.Revision=unknown"
      "-X ${t}.Branch=unknown"
      "-X ${t}.BuildUser=nix@nixpkgs"
      "-X ${t}.BuildDate=unknown"
      "-X ${t}.GoVersion=${lib.getVersion go}"
    ];

  preInstall = ''
    mkdir -p "$out/share/doc/perses" "$out/etc/perses"
    cp -a $src/docs/* $out/share/doc/perses
  '';

  postInstall = ''
    moveToOutput bin/percli $cli
  '';

  # https://hydra.nixos.org/build/130673870/nixlog/1
  # Test mock data uses 64 bit data without an explicit (u)int64
  doCheck = !(stdenv.isDarwin || stdenv.hostPlatform.parsed.cpu.bits < 64);

  passthru.tests = { inherit (nixosTests) perses; };

  meta = with lib; {
    description = "Service monitoring system and time series database";
    homepage = "https://perses.io";
    license = licenses.asl20;
    maintainers = with maintainers; [ fbegyn ];
  };
}
