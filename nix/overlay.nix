final: prev: rec {
  nhost-cli = final.callPackage ./nhost-cli.nix { };

  python = prev.python37;
}
