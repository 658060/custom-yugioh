{
  description = "A Nix-flake-based development environment for python";

  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";
    flake-utils.url = "git+https://github.com/numtide/flake-utils?shallow=1";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    # change this to change the python version
    # e.g "3.10"
    version = "3.12";
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        python = pkgs."python${builtins.replaceStrings ["."] [""] version}";
      in {
        devShells.default = pkgs.mkShellNoCC {
          venvDir = ".venv";

          packages = [
            python.pkgs.venvShellHook
            python.pkgs.uv
          ];

          env = {};

          postShellHook = ''

          '';
        };
      }
    );
}
