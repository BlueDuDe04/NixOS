{ inputs, config, pkgs, ... }:

{
  home.username = "mason";
  home.homeDirectory = "/home/mason";

  home.stateVersion = "22.11"; # Please read the comment before changing.

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  home.packages = with pkgs; [
    inputs.xremap.packages.${system}.xremap-wlroots
    # (pkgs.writeShellScriptBin "nv" ''nvim --cmd ":lua require 'mason'.init()" "$@"'')
    # waybar
    wl-clipboard
    grim
    slurp
    clipboard-jh
    wofi
    bottles

    # Apps
    qutebrowser
      # python311Packages.adblock

    firefox
    luakit
    librewolf
    wezterm
    pavucontrol
    obs-studio
    lapce
    helix
    ranger
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

    chromium
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
      comment = "All-in-one cross-platform voice and text chat for gamers";
    })

    gnome.gnome-calculator
    gnome.nautilus

      # blender
    godot_4
      # krita
    gimp

    # Nix
    nix-your-shell

    # Langs
    rustc
    go
    zig
    lua
    typescript
      # python311

    # LSPs
    rust-analyzer
    gopls
    zls
    lua-language-server
    nodePackages.typescript-language-server
    haskell-language-server
    rnix-lsp
    nil
      # python311Packages.python-lsp-server
    glslls

    # Formatters
    rustfmt
    gofumpt
    golines
    nixpkgs-fmt

    # Tools
    cargo
    gcc
    ghc
    ripgrep
    fd
    fzf
    cliphist
    wtype
      # python311Packages.pip

    (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  home.file = {
  };

  xdg.configFile."sway".source = ../sway;
  xdg.configFile."hypr/hyprland.conf".text = (import ./hypr.nix) inputs;
  xdg.configFile."xremap.yaml".text = (import ./xremap.nix) pkgs;
  xdg.configFile."waybar".source = ../waybar;
  xdg.configFile."starship.toml".source = ../starship.toml;

  # You can also manage environment variables but you will have to manually
  # source
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  # or
  #  /etc/profiles/per-user/mason/etc/profile.d/hm-session-vars.sh
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    DIRENV_LOG_FORMAT = "";
    CLIPBOARD_NOGUI = 1;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "BlueDuDe04";
    userEmail = "Bennettmason04@gmail.com";
  };

  programs.kitty = {
    enable = true;

    # package = pkgs.writeShellScriptBin "kitty" ''
    #   #!/bin/sh
    #
    #   ${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.kitty}/bin/kitty "$@"
    # '';
    package = pkgs.hello;

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
       libredirect
       vimium
       sidebery
      ];

      userChrome = builtins.readFile ../userChrome.css;

      settings = {
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
        "browser.newtabpage.pinned" = [{
          title = "New Tab";
          url = "chrome://browser/content/blanktab.html";
        }];
        "browser.toolbars.bookmarks.visibility" = "never";
        "signon.rememberSignons" = false;
        "browser.download.useDownloadDir" = false;

        # Not sure it works
        "extensions.allowPrivateBrowsingByDefault" = true;

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

  xdg.configFile."lf/icons".source = ../lf/icons;

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
      if command -v nix-your-shell > /dev/null; then
        nix-your-shell zsh | source /dev/stdin
      fi
    '';
  };

  programs.fish = {
    enable = true;
    # shellAbbrs = { nv = "nvim"; };
    shellInit = ''
      set fish_greeting

      set -Ux EDITOR nvim
      set -Ux BROWSER firefox
      set -Ux DIRENV_LOG_FORMAT ""
      set -Ux CLIPBOARD_NOGUI 1

      # alias nv="nvim"

      if command -q nix-your-shell
        nix-your-shell fish | source
      end

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

  xdg.configFile."fish/functions/lfcd.fish".source = ../lf/lfcd.fish;

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
