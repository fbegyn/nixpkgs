{ lib
, buildGoModule
, fetchFromGitHub
, installShellFiles
}:

buildGoModule rec {
  pname = "oh-my-posh";
  version = "14.2.4";

  src = fetchFromGitHub {
    owner = "jandedobbeleer";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-4o0Z3xXsVTr2dE5td/i2uQoaqsBGOMSrzt2X6C9gYbA=";
  };

  vendorHash = "sha256-ehG71B351u+LoXDuKQkuEdEpUdHslVU2HcPKUz6FAnQ=";

  sourceRoot = "source/src";

  nativeBuildInputs = [
    installShellFiles
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  tags = [
    "netgo"
    "osusergo"
    "static_build"
  ];

  postPatch = ''
    # this test requires internet access
    rm engine/migrate_glyphs_test.go
  '';

  postInstall = ''
    mv $out/bin/{src,oh-my-posh}
    mkdir -p $out/share/oh-my-posh
    cp -r ${src}/themes $out/share/oh-my-posh/
    installShellCompletion --cmd oh-my-posh \
      --bash <($out/bin/oh-my-posh completion bash) \
      --fish <($out/bin/oh-my-posh completion fish) \
      --zsh <($out/bin/oh-my-posh completion zsh)
  '';

  meta = with lib; {
    description = "A prompt theme engine for any shell";
    homepage = "https://ohmyposh.dev";
    changelog = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ lucperkins urandom ];
  };
}
