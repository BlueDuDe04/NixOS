{ inputs, system, stylixIgnore, ... }: {

  networking.hostName = "Desktop";

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

  home-manager = {
    extraSpecialArgs = { inherit inputs system; };

    users.mason = {
      imports = [ ../home ../home/wayland.nix stylixIgnore ];

      home.username = "mason"; home.homeDirectory = "/home/mason";

      services.syncthing.enable = true;

      wayland.windowManager.hyprland = {
        enable = true;
        enableNvidiaPatches = true;

        plugins = [
          inputs.hy3.packages.${system}.hy3
        ];

        extraConfig = (import ../home/hypr.nix) inputs ''
          monitor=HDMI-A-1,2560x1440@59.95100,0x0,1
          monitor=DP-1,2560x1440@59.95100,-1440x-580,1,transform,1
          monitor=DP-2,2560x1440@59.95100,2560x-495,1,transform,3

          exec-once = swaybg -o HDMI-A-1 -m stretch -i ~/git/NixOS/colorful-sky.jpg
          exec-once = swaybg -o DP-1 -m fill -i ~/git/NixOS/Colorful-Sky-Vertical.jpg
          exec-once = swaybg -o DP-2 -m fill -i ~/git/NixOS/Colorful-Sky-Vertical.jpg

          workspace = DP-1, 1
          workspace = DP-1, 2
          workspace = DP-1, 3

          workspace = HDMI-A-1, 4
          workspace = HDMI-A-1, 5
          workspace = HDMI-A-1, 6
          workspace = HDMI-A-1, 7

          workspace = DP-2, 8
          workspace = DP-2, 9
          workspace = DP-2, 0
        '';
      };
    };
  };
}
