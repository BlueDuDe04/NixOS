{
  description = "NixOS Flake";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations = {
      NixOS = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };

        modules = [
          ./os/configuration.nix
        ];
      };
    };

    homeConfigurations = {
      mason = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home/mason.nix
          { targets.genericLinux.enable = true; }
        ];
      };
    };
  };
}
