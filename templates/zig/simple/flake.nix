{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    zig.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, zig, zls, ... }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  in
    flake-utils.lib.eachSystem systems (system:
  let
    pkgs = import nixpkgs { inherit system; };
    zig = inputs.zig.packages.${system}.master;
    zls = inputs.zls.packages.${system}.zls;
  in {
    devShells.default = pkgs.mkShell {
      name = "zig";

      packages = [
        zig
        zls
      ];
    };
  });
}
