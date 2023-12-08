{ inputs, system, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  networking.hostName = "tv";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";
  
  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  services.dbus.enable = true;

  programs.kdeconnect.enable = true;

  services = {
    pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    xserver.displayManager = {
      defaultSession = "none+hyprland";

      lightdm = {
        enable = true;
        autoLogin.enable = true;
        autoLogin.user = "tv";
      };
    };

    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
  };

  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 80 443 22067 ];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 8000; to = 9010; }
    ];
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      ];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tv = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs system; };

    users.tv = {
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      home.username = "tv"; home.homeDirectory = "/home/tv";

      home.stateVersion = "22.11"; # Please read the comment before changing.

      wayland.windowManager.hyprland = {
        enable = true;

        # package = inputs.hyprland.packages.${system}.hyprland;

        plugins = [
          inputs.hy3.packages.${system}.hy3
        ];

        extraConfig = ''
          monitor=,highres,auto,1

          exec-once = wl-paste --watch cliphist store

          exec-once = xremap --watch ~/.config/xremap.yaml

          exec-once = swaybg -o * -m fill -i ~/git/NixOS/colorful-sky.jpg

          exec-once = nwg-drawer -r -mt 50 -mr 50 -mb 50 -ml 50

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

      programs.chromium = {
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

      xdg.configFile = let
          workspace = pkgs.writeShellScriptBin "run" ''
            pkill -USR1 nwg-drawer
            hyprctl keyword general:gaps_out 40
          '';
          nwg-drawer-run = pkgs.writeShellScriptBin "run" ''
            hyprctl keyword general:gaps_out 0
            if ! hyprctl activeworkspace -j | gojq '.windows'; then nwg-drawer; fi
          '';
      in {
        "starship.toml".source = ../starship.toml;
        "lf/icons".source = ../lf/icons;
        "fish/functions/lfcd.fish".source = ../lf/lfcd.fish;

        "xremap.yaml".text = ''
          keymap:
          - name: default mode
            remap:
              super: { 
                set_mode: workspace
                launch: ["bash", "-c", "${workspace}/bin/run"]
              }
            mode: default

          - name: workspace mode
            remap:
              Enter: {
                set_mode: default
                launch: ["bash", "-c", "${nwg-drawer-run}/bin/run]
              }
              right:
                launch: ["hyprctl", "dispatch", "workspace", "r+1"]
              left:
                launch: ["hyprctl", "dispatch", "workspace", "r-1"]
            mode: workspace
        '';
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
    };
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };
  
  environment.systemPackages = with pkgs; [
    # CLI
    git
    lazygit
    wget
    zip
    unzip
    killall
    htop
    ranger
    evtest
    pamixer
    brightnessctl
    acct

    # Tools
    ripgrep
    fd
    fzf
    gojq

    # System
    inputs.xremap.packages.${system}.xremap-wlroots

    # Wayland
    swaybg
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

    # Apps
    jellyfin-media-player
    plex-media-player
    freetube
    bottles
    pavucontrol
    ranger

    gnome.gnome-calculator
    gnome.nautilus
    gnome.zenity
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = ["FiraCode"]; })
  ];

  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # Do not change unless you know what you are doing!
  system.stateVersion = "22.11"; # Did you read the comment?
}
