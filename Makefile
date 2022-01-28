.PHONY: check
check:
	nix flake check --print-build-logs
