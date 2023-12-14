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

    hy3.url = "github:outfoxxed/hy3?ref=hl0.32.0";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, kmonad, stylix, ... }@inputs: 
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs { inherit system; };

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
            boot.loader.grub.device = "nodev";
          }];
        });
      };
    in
      (buildNixosSystems "Desktop" {
        specialArgs = { inherit inputs system stylixIgnore; };

        modules = [
          ./os ./os/desktop.nix

          kmonad.nixosModules.default { services.kmonad = {
            enable = true;
            keyboards = {
              keyboard = {
                device = "/dev/input/by-path/pci-0000:00:14.0-usb-0:1:1.0-event-kbd";
                config = builtins.readFile kmonad/colemak-dh-wide.kbd;
              };
            };
          };}

          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix ./stylix.nix
        ];
      })

      //

      (buildNixosSystems "Laptop" {
        specialArgs = { inherit inputs system stylixIgnore; };

        modules = [
          ./os ./os/laptop.nix

          kmonad.nixosModules.default { services.kmonad = {
            enable = true;
            keyboards = {
              framework = {
                device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
                config = builtins.readFile kmonad/colemak-dh-wide.kbd;
              };
            };
          };}

          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix ./stylix.nix
        ];
      })

      //

      (buildNixosSystems "Tv" {
        specialArgs = { inherit inputs system; };

        modules = [
          ./os os/tv.nix

          home-manager.nixosModules.home-manager
        ];
      })

      //

      (buildNixosSystems "Server" {
        specialArgs = { inherit inputs system; };

        modules = [
          ./os os/server.nix

          home-manager.nixosModules.home-manager {
            home-manager = {
              users.mason = { 
                imports = [ ./home ];
                home.username = "mason"; home.homeDirectory = "/home/mason";
              };
            };
          }
        ];
      })
    ;

    homeConfigurations = {
      mason = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = { inherit inputs system; };

        modules = [
          ./home home/wayland.nix {
            home = {
              username = "mason"; homeDirectory = "/home/mason";
              packages = [ inputs.nixgl.packages.${system}.nixGLIntel ];
            };

            targets.genericLinux.enable = true;

            wayland.windowManager.hyprland = {
              enable = true;
              plugins = [ inputs.hy3.packages.${system}.hy3 ];
              extraConfig = (import ./hypr.nix) inputs ''
                monitor=eDP-1,2256x1504@59.999,0x0,1.3
                exec-once = swaybg -m fill -i ~/git/NixOS/colorful-sky.jpg
              '';
            };
          }

          stylix.homeManagerModules.stylix ./stylix.nix stylixIgnore 
        ];
      };

      work = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = { inherit inputs system; };

        modules = [
          ./home home/wayland.nix {
            home = {
              username = "work"; homeDirectory = "/home/work";
              packages = [ inputs.nixgl.packages.${system}.nixGLIntel ];
            };

            targets.genericLinux.enable = true;

            wayland.windowManager.hyprland = {
              enable = true;
              plugins = [ inputs.hy3.packages.${system}.hy3 ];
              extraConfig = (import ./hypr.nix) inputs ''
                monitor=eDP-1,2256x1504@59.999,0x0,1.3
                exec-once = swaybg -m fill -i ~/git/NixOS/colorful-sky.jpg
              '';
            };

            programs.google-chrome = {
              enable = true;
              commandLineArgs = [ "--ozone-platform-hint=auto" ];
            };
          }

          stylix.homeManagerModules.stylix ./stylix.nix stylixIgnore
        ];
      };
    };

    templates = {
      zig = {
        path = templates/zig/simple;
        description = "A simple Zig template.";
      };
    };
  };
}
