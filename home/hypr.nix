inputs: let
  workspaces = func: builtins.concatStringsSep "\n\n" (builtins.genList (x: func (x + 1)) 10);
in ''
  monitor=eDP-1,2256x1504@59.999,0x0,1.3
  monitor=,highres,auto,1

  exec-once = wl-paste --watch cliphist store

  exec-once = xremap --device kmonad --watch ~/.config/xremap.yaml

  exec-once = swaybg -o eDP-1 -m fill -i ~/git/NixOS/colorful-sky.jpg

  exec-once = waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css

  plugin = ${inputs.hy3.packages.x86_64-linux.hy3}/lib/libhy3.so

  bind = SUPER, Q, killactive, 
  bind = SUPER_SHIFT, M, exit, 
  bind = SUPER, V, togglefloating, 
  bind = SUPER, P, pseudo, # dwindle
  bind = SUPER, J, togglesplit, # dwindle

  bindm = SUPER,mouse:272,movewindow
  bindm = SUPER,mouse:273,resizewindow

  # Move focus with $SUPER + arrow keys
  bind = SUPER, left, hy3:movefocus, l
  bind = SUPER, right, hy3:movefocus, r
  bind = SUPER, up, hy3:movefocus, u
  bind = SUPER, down, hy3:movefocus, d

  bind = SUPER_SHIFT, left, hy3:movewindow, l
  bind = SUPER_SHIFT, right, hy3:movewindow, r
  bind = SUPER_SHIFT, up, hy3:movewindow, u
  bind = SUPER_SHIFT, down, hy3:movewindow, d

  bind = SUPER, h, hy3:makegroup, v
  bind = SUPER, o, hy3:makegroup, h

  # Workspaces
  ${workspaces (x: let
    ws = toString (if x != 10 then x else 0);
  in ''
    bind = SUPER, ${ws}, workspace, ${toString x}
    bind = SUPER_SHIFT, ${ws}, movetoworkspace, ${toString x}''
  )}

  # Example windowrule v1
  # windowrule = float, ^(kitty)$
  # Example windowrule v2
  # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
  # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

  windowrule = float,^(org.gnome.Nautilus)$
  windowrule = float,^(org.gnome.Calculator)$
  windowrule = float,^(zenity)$

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

      gaps_in = 10
      gaps_out = 10
      border_size = 5
      col.active_border = rgba(AD8EE6ee) rgba(33ccffee) 45deg
      col.inactive_border = rgba(595959aa)

      layout = hy3
  }

  decoration {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      rounding = 6
      
      blur {
          enabled = true
          size = 4
          passes = 5
      }

      drop_shadow = yes
      shadow_range = 4
      shadow_render_power = 3
      col.shadow = rgba(1a1a1aee)
  }

  animations {
      enabled = yes

      # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

      bezier = myBezier, 0.05, 0.9, 0.1, 1.05

      animation = windows, 1, 7, myBezier
      animation = windowsOut, 1, 7, default, popin 80%
      animation = border, 1, 10, default
      animation = borderangle, 1, 8, default
      animation = fade, 1, 7, default
      animation = workspaces, 1, 6, default
  }

  dwindle {
      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
      preserve_split = yes # you probably want this
  }

  master {
      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      new_is_master = true
  }

  gestures {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more
      workspace_swipe = true
      workspace_swipe_forever = true
      # workspace_swipe_invert = true
      # workspace_swipe_min_speed_to_force=5
  }

  misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true

    enable_swallow = true
    swallow_regex = ^(kitty)$
  }
''
