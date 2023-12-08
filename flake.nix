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

    hyprland.url = "github:hyprwm/Hyprland?ref=v0.32.3";
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
    };
    stylixIgnore = {
      stylix.targets.hyprland.enable = false;
      stylix.targets.wezterm.enable = false;
      stylix.targets.kitty.enable = false;
      stylix.targets.fish.enable = false;
      stylix.targets.vim.enable = false;
    };
  in {
    nixosConfigurations = let 
      buildNixosSystems = name: config: {
        "${name}" = nixpkgs.lib.nixosSystem (config // { 
          modules = config.modules ++ [{
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;
            boot.loader.efi.efiSysMountPoint = "/boot/efi";
          }];
        });

        "${name}-no-efi" = nixpkgs.lib.nixosSystem (config // {
          modules = config.modules ++ [{
            boot.loader.grub.enable = true;
            boot.loader.grub.device = "/dev/sdb";
          }];
        });
      };
    in
      (buildNixosSystems "Desktop" {
        specialArgs = { inherit inputs system stylixIgnore; };

        modules = [
          ./os ./os/desktop.nix

          stylix.nixosModules.stylix ./stylix.nix
        ];
      })

      //

      (buildNixosSystems "Laptop" {
        specialArgs = { inherit inputs system stylixIgnore; };

        modules = [
          ./os ./os/laptop.nix

          stylix.nixosModules.stylix ./stylix.nix
        ];
      })

      //

      (buildNixosSystems "Tv" {
        specialArgs = { inherit inputs system; };

        modules = [
          ./os/tv.nix
        ];
      })

      //

      (buildNixosSystems "Server" {
        specialArgs = { inherit inputs system; };

        modules = [
          ./os/server.nix
        ];
      })
    ;

    homeConfigurations = {
      mason = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = { inherit inputs system; };

        modules = [
          ./home ./home/mason.nix

          stylix.homeManagerModules.stylix ./stylix.nix stylixIgnore 
        ];
      };

      work = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = { inherit inputs system; };

        modules = [
          ./home ./home/work.nix

          stylix.homeManagerModules.stylix ./stylix.nix stylixIgnore
        ];
      };
    };
  };
}
