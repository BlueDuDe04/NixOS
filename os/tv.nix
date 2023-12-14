{ inputs, system, pkgs, ... }: {

  networking.hostName = "tv";

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs system; };

    users.mason = {
      imports = [ ../home ../home/wayland.nix ];

      home.username = "mason"; home.homeDirectory = "/home/mason";

      wayland.windowManager.hyprland = {
        enable = true;

        plugins = [ inputs.hy3.packages.${system}.hy3 ];

        extraConfig = ''
          monitor=,highres,auto,1

          exec-once = wl-paste --watch cliphist store

          exec-once = xremap --watch ~/.config/xremap.yaml

          exec-once = swaybg -o * -m fill -i ${../Sunset-Deer-Wallpaper.jpg}

          exec-once = nwg-drawer -r -mt 50 -mr 50 -mb 50 -ml 50
          exec-once = nwg-drawer

          bindn = , mouse:272, hy3:focustab, mouse

          input {
            repeat_delay=200
            repeat_rate=60
            touchpad {
              natural_scroll = yes
            }
            sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
          }

          general {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more
              gaps_in = 0
              gaps_out = 0
              border_size = 5
              col.active_border = rgba(AD8EE6FF) rgba(33ccffFF) 45deg
              col.inactive_border = rgba(595959FF)
              layout = hy3
          }

          misc {
            disable_hyprland_logo = true
            disable_splash_rendering = true
          }

          xwayland {
            force_zero_scaling = true
          }

          plugin {
            hy3 {
              no_gaps_when_only = true
              tab_first_window = true

              tabs {
                height = 18
                text_font = "FiraCode Nerd Font Bold"
                text_height = 10
                text_padding = 4
                col.active = rgba(AD8EE6FF)
                col.inactive = rgba(595959FF)
              }
            }
          }
        '';
      };

      xdg.configFile = {
        "xremap.yaml".text = let
          workspace = pkgs.writeShellScriptBin "run" ''
            pkill -USR1 nwg-drawer
            hyprctl keyword general:gaps_out 40
          '';
          nwg-drawer-run = pkgs.writeShellScriptBin "run" ''
            hyprctl keyword general:gaps_out 0
            if ! hyprctl activeworkspace -j | gojq '.windows'; then nwg-drawer; fi
          '';
        in ''
          modmap:
            - name: Global
              remap:
                Super_L: brightnessup

          keymap:   
          - name: default mode
            remap:
              brightnessup:
                [ { set_mode: workspace },
                { launch: ["bash", "-c", "${workspace}/bin/run"] } ]
            mode: default

          - name: workspace mode
            remap:
              Enter:
                [ { set_mode: default },
                { launch: ["bash", "-c", "${nwg-drawer-run}/bin/run"] } ]
              right:
                launch: ["hyprctl", "dispatch", "workspace", "r+1"]
              left:
                launch: ["hyprctl", "dispatch", "workspace", "r-1"]
              q:
                launch: ["hyprctl", "dispatch", "killactive"]
            mode: workspace
        '';
      };
    };
  };
}
