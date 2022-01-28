{ buildGoModule, fetchFromGitHub, lib, installShellFiles }:

buildGoModule rec {
  pname = "nhost-cli";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "nhost";
    repo = "cli";
    rev = "v${version}";
    sha256 = "sha256-UXxLASuieM8doKm6n3LFFr5mAfXhvp1lggJ7hzfnRRY=";
  };

  vendorSha256 = "sha256-LT4AgB8xkqV4yipTGytH1A9kt6ZicFtzQ+7aCVrSWCI=";

  doCheck = false;

  subPackages = [ "." ];

  meta = with lib; {
    description = "Nhost CLI";
    homepage = "https://nhost.io";
    license = licenses.mit;
    maintainers = [ "@dbarrosop" ];
  };
}
