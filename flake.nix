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
    nixosConfigurations = {
      Desktop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };

        modules = [
          ./os/configuration.nix { 
            services.kmonad = {
              enable = true;
              keyboards = {
                keyboard = {
                  device = "/dev/input/by-path/pci-0000:00:14.0-usb-0:1:1.0-event-kbd";
                  config = builtins.readFile kmonad/colemak-dh-wide.kbd;
                };
              };
            };
            services.xserver.videoDrivers = [ "nvidia" ];
            hardware.nvidia = {
              nvidiaSettings = true;
              modesetting.enable = true;
              powerManagement.enable = true;
            };
            environment.sessionVariables = {
              WLR_NO_HARDWARE_CURSORS = "1";
              NIXOS_OZONE_WL = "1";
            };
          }

          stylix.nixosModules.stylix ./stylix.nix {
            home-manager.sharedModules = [
              stylixIgnore
              { wayland.windowManager.hyprland = {
                  enable = true;
                  enableNvidiaPatches = true;

                  # package = inputs.hyprland.packages.${system}.hyprland;

                  plugins = [
                    inputs.hy3.packages.${system}.hy3
                  ];

                  extraConfig = (import ./home/hypr.nix) inputs ''
                    monitor=DP-3,2560x1440@59.95100,0x0,1
                    monitor=HDMI-A-1,2560x1440@59.95100,2560x-545,1,transform,3

                    exec-once = swaybg -o DP-3 -m stretch -i ~/git/NixOS/colorful-sky.jpg
                    exec-once = swaybg -o HDMI-A-1 -m fill -i ~/git/NixOS/Colorful-Sky-Vertical.jpg

                    workspace = DP-3, 9
                    workspace = DP-3, 5
                    workspace = DP-3, 1
                    workspace = DP-3, 3
                    workspace = DP-3, 7

                    workspace = HDMI-A-1, 6
                    workspace = HDMI-A-1, 2
                    workspace = HDMI-A-1, 0
                    workspace = HDMI-A-1, 4
                    workspace = HDMI-A-1, 8
                  '';
                };
              }
            ];
          }
        ];
      };

      Laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };

        modules = [
          ./os/configuration.nix { 
            services.kmonad = {
              enable = true;
              keyboards = {
                framework = {
                  device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
                  config = builtins.readFile kmonad/colemak-dh-wide.kbd;
                };
              };
            };
          }

          stylix.nixosModules.stylix ./stylix.nix {
            home-manager.sharedModules = [
              stylixIgnore
              { wayland.windowManager.hyprland = {
                  enable = true;

                  package = inputs.hyprland.packages.${system}.hyprland;

                  plugins = [
                    inputs.hy3.packages.${system}.hy3
                  ];

                  extraConfig = (import ./home/hypr.nix) inputs ''
                    monitor=eDP-1,2256x1504@59.999,0x0,1.3

                    exec-once = swaybg -o eDP-1 -m fill -i ~/git/NixOS/colorful-sky.jpg
                  '';
                };
              }
            ];
          }
        ];
      };

      Server = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };

        modules = [
          ./os/server.nix
        ];
      };
    };

    homeConfigurations = {
      mason = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = { inherit inputs system; };

        modules = [
          { home.username = "mason";
            home.homeDirectory = "/home/mason";
            targets.genericLinux.enable = true;

            wayland.windowManager.hyprland = {
              enable = true;

              package = inputs.hyprland.packages.${system}.hyprland;

              plugins = [
                inputs.hy3.packages.${system}.hy3
              ];

              extraConfig = (import ./home/hypr.nix) inputs ''
                monitor=eDP-1,2256x1504@59.999,0x0,1.3

                exec-once = swaybg -o eDP-1 -m fill -i ~/git/NixOS/colorful-sky.jpg
              '';
            };
          } ./home

          stylix.homeManagerModules.stylix ./stylix.nix stylixIgnore 
        ];
      };

      work = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = { inherit inputs system; };

        modules = [
          { home.username = "work";
            home.homeDirectory = "/home/work";
            targets.genericLinux.enable = true;

            wayland.windowManager.hyprland = {
              enable = true;

              package = inputs.hyprland.packages.${system}.hyprland;

              plugins = [
                inputs.hy3.packages.${system}.hy3
              ];

              extraConfig = (import ./home/hypr.nix) inputs ''
                monitor=eDP-1,2256x1504@59.999,0x0,1.3

                exec-once = swaybg -o eDP-1 -m fill -i ~/git/NixOS/colorful-sky.jpg
              '';
            };

            programs.google-chrome = {
              enable = true;

              commandLineArgs = [
                "--ozone-platform-hint=auto"
              ];
            };
          } ./home

          stylix.homeManagerModules.stylix ./stylix.nix stylixIgnore
        ];
      };
    };
  };
}
