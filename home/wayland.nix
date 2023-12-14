{inputs, system, pkgs, ...}: {

  xdg.configFile = {
    "sway".source = ../sway;
    # "hypr/hyprland.conf".text = (import ./hypr.nix) inputs;
    "xremap.yaml".text = (import ./xremap.nix) pkgs;
    "waybar".source = ../waybar;
  };

  home = {
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "firefox";
      CLIPBOARD_NOGUI = 1;
    };

    packages = with pkgs; [
      # System
      (pkgs.nerdfonts.override { fonts = [ "FiraCode" "VictorMono" "JetBrainsMono" ]; })
      inputs.xremap.packages.${system}.xremap-wlroots

      # Wayland
      # waybar
      swaybg
      waylock
      fuzzel
      nwg-drawer
      wofi
      hyprpicker

      grim
      slurp
      swappy
      wf-recorder

      wl-clipboard
      cliphist
      clipboard-jh

      wtype

      # Tools
      ripgrep
      fd
      fzf
      remmina
      openfortivpn
      gnome.zenity
      helix
      ranger

      # Apps
      freetube
      bottles
      jellyfin-media-player
      plex-media-player
      wezterm
      pavucontrol
      obs-studio
      luakit
      lapce

      blender
      godot_4
      krita
      gimp

      gnome.gnome-calculator
      gnome.nautilus

      # Dbeaver
      (pkgs.writeShellScriptBin "dbeaver" ''GDK_BACKEND=x11 GTK_THEME=Adwaita ${dbeaver}/bin/dbeaver'')
      (makeDesktopItem {
        name = "dbeaver";
        exec = "dbeaver";
        icon = "dbeaver";
        desktopName = "dbeaver";
        comment = "SQL Integrated Development Environment";
        genericName = "SQL Integrated Development Environment";
        categories = [ "Development" ];
      })

      # Discord
      (pkgs.writeShellScriptBin "discord" ''chromium --app=https://discord.com/channels/@me'')
      (makeDesktopItem {
        name = "discord";
        exec = "discord";
        icon = "discord";
        desktopName = "discord";
        comment = "All-in-one cross-platform voice and text chat for gamers";
      })

      # Slack
      (pkgs.writeShellScriptBin "slack" ''chromium --app=https://app.slack.com/client/T7C5M4HRS/C014RKD8T3R'')
      (makeDesktopItem {
        name = "slack";
        exec = "slack";
        icon = "slack";
        desktopName = "slack";
        comment = "All-in-one cross-platform voice and text chat for work";
      })
    ];
  };

  programs = {
    kitty = {
      enable = true;

      theme = "Tokyo Night";

      extraConfig = ''
        shell fish
        background_opacity 0.9
        cursor_blink_interval 0
        touch_scroll_multiplier 10.0
        window_padding_width 0 6

        font_family      Victor Mono Nerd Font
        bold_font        auto
        italic_font      auto
        bold_italic_font auto
        font_size 13
      '';
    };

    firefox = {
      enable = true;

      profiles.mason = {
        extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
         ublock-origin 
         sponsorblock
         dearrow
         darkreader
         bitwarden
         adsum-notabs
         libredirect
         vimium
         sidebery
        ];

        userChrome = builtins.readFile ../userChrome.css;

        settings = {
          # Theme
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          # New Tab
          "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
          "browser.newtabpage.enabled" = false;

          # Options
          "browser.toolbars.bookmarks.visibility" = "never";
          "signon.rememberSignons" = false;
          "browser.download.useDownloadDir" = false;
          "browser.aboutConfig.showWarning" = false;

          # Security
          "dom.security.https_only_mode" = true;
        };

        search = {
          default = "DuckDuckGo";

          force = true;

          order = [
            "DuckDuckGo"
            "Nix Packages"
            "NixOs Wiki"
          ];

          engines = {
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };

            "NixOS Wiki" = {
              urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
              iconUpdateURL = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nw" ];
            };
          };
        };
      };
    };

    chromium = {
      enable = true;

      # package = pkgs.ungoogled-chromium;

      commandLineArgs = [
        "--ozone-platform-hint=auto"
      ];

      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
        { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # SponsorBlock
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
      ];
    };
  };
}
