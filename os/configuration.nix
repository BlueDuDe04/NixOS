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

  networking.hostName = "NixOS";
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
    pam.services.mason.updateWtmp = true;
  };

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
    gvfs.enable = true;
    xserver = {
      libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
      };
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
      audio.enable = true;
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

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-ocl
        vaapiIntel
        libglvnd
      ];
    };

    uinput.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mason = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" "input" "uinput" ];
    # packages = with pkgs; [];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      mason = import ../home/mason.nix;
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
    mpv
    killall
    htop
    openvpn
    ranger
    evtest
    pamixer
    brightnessctl
    imagemagick
    acct

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

    hyprland

    # Other
    docker
    docker-compose
    seatd
    polkit
    mesa
    glxinfo
    openssl
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
