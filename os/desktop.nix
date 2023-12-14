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
    };
  };
}
