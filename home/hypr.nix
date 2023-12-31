inputs: screens: let
  workspaces = func: builtins.concatStringsSep "\n\n" (builtins.genList (x: func (x + 1)) 10);
in ''
  ${screens}
  monitor=,highres,auto,1

  exec-once = wl-paste --watch cliphist store

  exec-once = xremap --device kmonad --watch ~/.config/xremap.yaml

  exec-once = waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css

  # plugin = ${inputs.hy3.packages.x86_64-linux.hy3}/lib/libhy3.so

  bind = SUPER, Q, killactive, 
  bind = SUPER_SHIFT, M, exit, 
  bind = SUPER_SHIFT, F, togglefloating, 
  # bind = SUPER, P, pseudo, # dwindle
  # bind = SUPER, J, togglesplit, # dwindle
  bind = SUPER, F, fullscreen 

  bindm = SUPER,mouse:272,movewindow
  bindm = SUPER,mouse:273,resizewindow

  # Move focus with $SUPER + arrow keys
  bind = SUPER, left, hy3:movefocus, l, visible
  bind = SUPER, down, hy3:movefocus, d, visible
  bind = SUPER, up, hy3:movefocus, u, visible
  bind = SUPER, right, hy3:movefocus, r, visible

  bind = SUPER_SHIFT, left, hy3:movewindow, l, once, visible
  bind = SUPER_SHIFT, down, hy3:movewindow, d, once, visible
  bind = SUPER_SHIFT, up, hy3:movewindow, u, once, visible
  bind = SUPER_SHIFT, right, hy3:movewindow, r, once, visible

  bind = SUPER_CONTROL, right, resizeactive, 30 0
  bind = SUPER_CONTROL, down, resizeactive, 0 30
  bind = SUPER_CONTROL, up, resizeactive, 0 -30
  bind = SUPER_CONTROL, left, resizeactive, -30 0

  bind = SUPER_ALT, left, hy3:focustab, l, wrap
  bind = SUPER_ALT, down, hy3:changefocus, lower
  bind = SUPER_ALT, up, hy3:changefocus, raise
  bind = SUPER_ALT, right, hy3:focustab, r, wrap

  bindn = , mouse:272, hy3:focustab, mouse

  bind = SUPER, H, hy3:makegroup, v
  bind = SUPER, O, hy3:makegroup, h
  bind = SUPER, T, hy3:makegroup, tab

  bind = SUPER_SHIFT, O, hy3:changegroup, opposite
  bind = SUPER_SHIFT, T, hy3:changegroup, toggletab

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
      col.active_border = rgba(AD8EE6FF) rgba(33ccffFF) 45deg
      col.inactive_border = rgba(595959FF)

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

      drop_shadow = no
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

  xwayland {
    force_zero_scaling = true
  }

  plugin {
    hy3 {
      no_gaps_when_only = true

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
''
