{ inputs, system, config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    stateVersion = "22.11"; # Please read the comment before changing.

    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "firefox";
      DIRENV_LOG_FORMAT = "";
      CLIPBOARD_NOGUI = 1;
    };

    file = {};
  };

  xdg.configFile = {
    "sway".source = ../sway;
    # "hypr/hyprland.conf".text = (import ./hypr.nix) inputs;
    "xremap.yaml".text = (import ./xremap.nix) pkgs;
    "waybar".source = ../waybar;
    "starship.toml".source = ../starship.toml;
    "lf/icons".source = ../lf/icons;
    "fish/functions/lfcd.fish".source = ../lf/lfcd.fish;
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  home.packages = with pkgs; [
    # System
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
    inputs.xremap.packages.${system}.xremap-wlroots
    inputs.nixgl.packages.${system}.nixGLIntel

    # Wayland
    swaybg
    wofi
    hyprpicker

    grim
    slurp

    clipboard-jh
    wl-clipboard
    cliphist

    wtype

    # Tools
    ripgrep
    fd
    fzf

    # Apps
    bottles
    luakit
    wezterm
    pavucontrol
    obs-studio
    lapce
    helix
    ranger

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

  programs.git = {
    enable = true;
    userName = "BlueDuDe04";
    userEmail = "Bennettmason04@gmail.com";
  };

  wayland.windowManager.hyprland = {
    enable = true;

    package = inputs.hyprland.packages."x86_64-linux".hyprland;

    plugins = [
      inputs.hy3.packages."x86_64-linux".hy3
    ];

    extraConfig = (import ./hypr.nix) inputs;
  };

  programs.kitty = {
    enable = true;

    theme = "Tokyo Night";

    extraConfig = ''
      shell fish
      background_opacity 0.9
      cursor_blink_interval 0
      touch_scroll_multiplier 10.0
      window_padding_width 0 6

      font_family FiraCode Nerd Font SemBd
      bold_font FiraCode Nerd Font Bold
      bold_italic_font FiraCode Nerd Font Bold
      font_size 12
    '';
  };

  programs.firefox = {
    enable = true;

    profiles.mason = {
      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
       ublock-origin 
       darkreader
       bitwarden
       adsum-notabs
       libredirect
       vimium
       sidebery
      ];

      userChrome = builtins.readFile ../userChrome.css;

      settings = {
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
        "browser.newtabpage.enabled" = false;

        "browser.toolbars.bookmarks.visibility" = "never";
        "signon.rememberSignons" = false;
        "browser.download.useDownloadDir" = false;

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

  programs.chromium = {
    enable = true;

    # package = pkgs.ungoogled-chromium;

    commandLineArgs = [
      "--ozone-platform-hint=auto"
    ];

    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
    ];
  };

  programs.lf = {
    enable = true;

    settings = {
      preview = true;
      hidden = true;
      drawbox = true;
      icons = true;
      ignorecase = true;
    };

    # commands = {
    # };

    keybindings = {
      "<esc>" = '':quit'';
    };

    extraConfig = 
    let 
      previewer = 
        pkgs.writeShellScriptBin "pv.sh" ''
        file=$1
        w=$2
        h=$3
        x=$4
        y=$5
        
        if [[ "$( ${pkgs.file}/bin/file -Lb --mime-type "$file")" =~ ^image ]]; then
            ${pkgs.kitty}/bin/kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
            exit 1
        fi
        
        ${pkgs.pistol}/bin/pistol "$file"
      '';

      cleaner = pkgs.writeShellScriptBin "clean.sh" ''
        ${pkgs.kitty}/bin/kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
      '';
    in ''
      set cleaner ${cleaner}/bin/clean.sh
      set previewer ${previewer}/bin/pv.sh
    '';
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      nv = "nvim";
    };

    initExtra = ''
      ${pkgs.nix-your-shell}/bin/nix-your-shell zsh | source /dev/stdin
    '';
  };

  programs.fish = {
    enable = true;

    shellInit = ''
      set fish_greeting

      ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source

      bind \co 'set old_tty (stty -g); stty sane; lfcd; stty $old_tty; commandline -f repaint'

      # TokyoNight Color Palette
      set -l foreground c0caf5
      set -l selection 283457
      set -l comment 565f89
      set -l red f7768e
      set -l orange ff9e64
      set -l yellow e0af68
      set -l green 9ece6a
      set -l purple 9d7cd8
      set -l cyan 7dcfff
      set -l pink bb9af7

      # Syntax Highlighting Colors
      set -g fish_color_normal $foreground
      set -g fish_color_command $cyan
      set -g fish_color_keyword $pink
      set -g fish_color_quote $yellow
      set -g fish_color_redirection $foreground
      set -g fish_color_end $orange
      set -g fish_color_error $red
      set -g fish_color_param $purple
      set -g fish_color_comment $comment
      set -g fish_color_selection --background=$selection
      set -g fish_color_search_match --background=$selection
      set -g fish_color_operator $green
      set -g fish_color_escape $pink
      set -g fish_color_autosuggestion $comment

      # Completion Pager Colors
      set -g fish_pager_color_progress $comment
      set -g fish_pager_color_prefix $cyan
      set -g fish_pager_color_completion $foreground
      set -g fish_pager_color_description $comment
      set -g fish_pager_color_selected_background --background=$selection
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.go = {
    enable = true;
    goPath = ".go";
  };
}
