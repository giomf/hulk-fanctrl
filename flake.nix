{
  description = "Dev environment for HULKs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
  };

  outputs = { self, nixpkgs, flake-utils, naersk }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
          naerskLib = pkgs.callPackage naersk { };
          src = ./.;
          nativBuildInputs = with pkgs; [];
          buildInputs = with pkgs; [
            cargo
            rustc
            rustfmt

            llvmPackages.clang
          ];
           env = {
            LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath buildInputs}";
            LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
          };
        in
        rec {
          packages = rec {
            default = naerskLib.buildPackage {
              inherit src nativBuildInputs  buildInputs env;
            };
          };
          devShells.default = pkgs.mkShell rec {
            inherit nativBuildInputs buildInputs env;
          };
        }
      );
}
