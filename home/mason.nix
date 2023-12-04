{ inputs, system }: {
  home.username = "mason";
  home.homeDirectory = "/home/mason";
  targets.genericLinux.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;

    # package = inputs.hyprland.packages.${system}.hyprland;

    plugins = [
      inputs.hy3.packages.${system}.hy3
    ];

    extraConfig = (import ./hypr.nix) inputs ''
      monitor=eDP-1,2256x1504@59.999,0x0,1.3

      exec-once = swaybg -o eDP-1 -m fill -i ~/git/NixOS/colorful-sky.jpg
    '';
  };
}
