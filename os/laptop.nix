{ inputs, system, stylixIgnore, ... }: {
  networking.hostName = "Laptop";

  home-manager = {
    extraSpecialArgs = { inherit inputs system; };

    users.mason = {
      imports = [ ../home ../home/wayland.nix stylixIgnore ];

      home.username = "mason"; home.homeDirectory = "/home/mason";

      services.syncthing.enable = true;

      wayland.windowManager.hyprland = {
        enable = true;

        package = inputs.hyprland.packages.${system}.default;

        plugins = [ inputs.hy3.packages.${system}.hy3 ];

        extraConfig = (import ../home/hypr.nix) inputs ''
          monitor=eDP-1,2256x1504@59.999,0x0,1.3

          exec-once = swaybg -o eDP-1 -m fill -i ~/git/NixOS/colorful-sky.jpg
        '';
      };
    };
  };
}
