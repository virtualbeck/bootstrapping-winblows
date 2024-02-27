{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "ecs-cli";
  version = "0.5.2";
  doCheck = false;
  vendorHash = "sha256-3UCDMlSJf7h07gov8xOlwl8mL3slTgFEGjfjELpQOrE=";
  # vendorHash = lib.fakeHash; # do this first, then paste output into above `vendorHash`, and comment this

  src = fetchFromGitHub {
    owner = "justmiles";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-9X+mf5UMGB75wn06vlEfFbleCmhhstDbslzrKiK11qk=";
    # sha256 = lib.fakeSha256; # do this first, then paste output into above `hash`, and comment this
  };

  ldflags = [
    "-X main.version=${version}"
  ];

  postInstall = ''
    mv $out/bin/${pname} $out/bin/ecs
  '';

  meta = with lib; {
    description = "Run ad-hoc containers on ECS";
    changelog = "https://github.com/${src.owner}/${pname}/releases/tag/v${version}";
    homepage = "https://github.com/${src.owner}/${pname}";
    platforms = platforms.linux ++ platforms.darwin ++ platforms.windows;
    license = licenses.mit;
    maintainers = with maintainers; [ src.owner ];
    mainProgram = pname;
  };
}