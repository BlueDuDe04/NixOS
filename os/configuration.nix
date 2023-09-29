{ inputs, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      inputs.kmonad.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "NixOS"; # Define your hostname.
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
  
  security.rtkit.enable = true;
  security.polkit.enable = true;

  programs.river = {
    enable = true;
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };


  services = {
    xserver = {

      # xkbOptions = "compose:ralt";
      # layout = "us";
      # xkbVariant = ",colemak_dh";
      # xkbOptions = "grp:alt_space_toggle";

      libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
      };

      # displayManager.startx.enable = true;
      # enable = true;
      # displayManager = {
      #   lightdm.enable = true;
      #   defaultSession = "none+bspwm";
      # };
      # windowManager.bspwm.enable = true;
    };

    greetd ={
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
          user = "greeter";
       };
      };
    };
    
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    
    kmonad = {
      enable = true;
      keyboards = {
        "laptop" = {
          device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
          config = builtins.readFile ../kmonad/colemak-dh-wide.kbd;
        };
      };
    };
  };
  
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mason = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    # packages = with pkgs; [];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      mason = import ../home/mason.nix;
    };
    sharedModules = [{
      # stylix.targets.wezterm.enable = false;
      # stylix.targets.fish.enable = false;
      # stylix.targets.vim.enable = false;
    }];
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # CLI
    git
    lazygit
    wget
    zip
    unzip
    mpv
    killall
    htop
    openvpn
    ranger
    evtest
    pamixer
    brightnessctl
    imagemagick

    # Apps
    firefox
    wezterm
    neovim

    # Wayland 
    wayland
    xwayland
    xdg-desktop-portal-wlr

    eww-wayland
    wlr-randr
    waybar
    wofi
    swww
    grim
    slurp
    swappy
    wl-clipboard
    wf-recorder

    swayfx
    swaybg
    swaylock
    swayidle

    river
    river-luatile
    river-tag-overlay

    # X11
    #rofi
    #picom
    #polybar
    #bspwm
    #sxhkd
    #nitrogen

    # Other
    docker
    docker-compose
    seatd
    polkit
    mesa
    glxinfo
    openssl
    
    # (builtins.getFlake "path:/home/bluedude/Documents/code/dwl").packages.x86_64-linux.default
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


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
