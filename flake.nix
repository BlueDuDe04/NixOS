{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:guibou/nixGL";

    stylix.url = "github:danth/stylix";

    kmonad.url = "github:kmonad/kmonad?dir=nix";

    xremap.url = "github:xremap/nix-flake";

    hyprland.url = "github:hyprwm/Hyprland?ref=v0.32.0";
    hy3.url = "github:outfoxxed/hy3?ref=hl0.32.0";
    hy3.inputs.hyprland.follows = "hyprland";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ inputs.nixgl.overlay ];
    };
  in {
    nixosConfigurations = {
      NixOS = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };

        modules = [
          ./os/configuration.nix

          stylix.nixosModules.stylix ./stylix.nix {
            home-manager.sharedModules = [{
              stylix.targets.hyprland.enable = false;
              stylix.targets.wezterm.enable = false;
              stylix.targets.kitty.enable = false;
              stylix.targets.fish.enable = false;
              stylix.targets.vim.enable = false;
            }];
          }
        ];
      };
    };

    homeConfigurations = {
      mason = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = { inherit inputs system; };

        modules = [
          ./home/mason.nix { targets.genericLinux.enable = true; }

          stylix.homeManagerModules.stylix ./stylix.nix {
            stylix.targets.wezterm.enable = false;
            stylix.targets.kitty.enable = false;
            stylix.targets.fish.enable = false;
            stylix.targets.vim.enable = false;
          }
        ];
      };
    };
  };
}
