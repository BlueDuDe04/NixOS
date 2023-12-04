{ inputs, system, stylixIgnore, ... }: {
  networking.hostName = "Laptop";
  services.kmonad = {
    enable = true;
    keyboards = {
      framework = {
        device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        config = builtins.readFile ../kmonad/colemak-dh-wide.kbd;
      };
    };
  };

  home-manager.sharedModules = [
    stylixIgnore
    { wayland.windowManager.hyprland = {
        enable = true;

        # package = inputs.hyprland.packages.${system}.hyprland;

        plugins = [
          inputs.hy3.packages.${system}.hy3
        ];

        extraConfig = (import ../home/hypr.nix) inputs ''
          monitor=eDP-1,2256x1504@59.999,0x0,1.3

          exec-once = swaybg -o eDP-1 -m fill -i ~/git/NixOS/colorful-sky.jpg
        '';
      };
    }
  ];
}
