{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";

    kmonad.url = "github:kmonad/kmonad?dir=nix";

    transparent-nvim.url = "github:xiyaowong/transparent.nvim";
    transparent-nvim.flake = false;
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs: 
  let
    system = "x86_64-linux";
    # pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations = {
      NixOS = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };

        modules = [
          ./os/configuration.nix
          stylix.nixosModules.stylix
          ./stylix.nix
        ];
      };
    };

    homeConfigurations = {
      mason = home-manager.lib.homeManagerConfiguration {
        inherit inputs;

        modules = [
          ./home/mason.nix
          stylix.homeManagerModules.stylix
          ./stylix.nix
          # { targets.genericLinux.enable = true; }
        ];
      };
    };
  };
}
