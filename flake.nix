{
  description = "Nhost Hasura Storage";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.11";
    nix-filter.url = "github:numtide/nix-filter";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        localOverlay = import ./nix/overlay.nix;
        overlays = [ localOverlay ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        buildInputs = with pkgs; [
        ];

        nativeBuildInputs = with pkgs; [
          poetry
          python
        ];

        pythonDeps = [
          (pkgs.poetry2nix.mkPoetryEnv {
            projectDir = ./.;
            python = pkgs.python;
          })
        ];


        src = ./.;

        nix-src = nix-filter.lib.filter {
          root = ./.;
          include = [
            (nix-filter.lib.matchExt "nix")
          ];
        };

        name = "nornir-nhost";
        version = nixpkgs.lib.fileContents ./VERSION;
      in
      {

        checks = {
          nixpkgs-fmt = pkgs.runCommand "check-nixpkgs-fmt"
            {
              nativeBuildInputs = with pkgs;
                [
                  nixpkgs-fmt
                ];
            }
            ''
              mkdir $out
              nixpkgs-fmt --check ${nix-src}
            '';

          black = pkgs.runCommand "check-black"
            {
              nativeBuildInputs = pythonDeps;
            }
            ''
              mkdir $out
              cd $out
              cp -r ${src}/* .

              black --check .
            '';


          pylama = pkgs.runCommand "check-pylama"
            {
              nativeBuildInputs = pythonDeps;
            }
            ''
              mkdir $out
              cd $out
              cp -r ${src}/* .

              pylama .
            '';

          mypy = pkgs.runCommand "check-mypy"
            {
              nativeBuildInputs = pythonDeps;
            }
            ''
              mkdir $out
              cd $out
              cp -r ${src}/* .

              mypy .
            '';

          pytest = pkgs.runCommand "check-pytest"
            {
              nativeBuildInputs = pythonDeps;
            }
            ''
              mkdir $out
              cd $out
              cp -r ${src}/* .

              pytest -vs .
            '';
        };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-fmt
            nhost-cli
            hasura-cli
            gnumake
            gnused
          ] ++ buildInputs ++ nativeBuildInputs;
        };


      }

    );


}
