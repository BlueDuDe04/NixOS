{ inputs, system, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.kmonad.nixosModules.default
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  networking.hostName = "Server";
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

  services.dbus.enable = true;

  services = {
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
        keyboard = {
          device = "/dev/input/by-path/pci-0000:00:14.0-usb-0:3:1.0-event-kbd";
          config = builtins.readFile ../kmonad/colemak-dh-wide.kbd;
        };
      };
    };

    nginx = {
      enable = true;

      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."192.168.0.40" =  {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8384";
          proxyWebsockets = true;
        };
      };

      virtualHosts."192.168.0.3" =  {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
        };
      };
    };

    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };

    # Set: <insecureSkipHostcheck>true</insecureSkipHostcheck> in <gui>...</gui>
    # In: /var/lib/syncthing/.config/syncthing/config.xml
    # https://docs.syncthing.net/users/faq.html#why-do-i-get-host-check-error-in-the-gui-api
    syncthing.enable = true;

    # Set: sudo setfacl -m u:jellyfin:rx /media/*
    # https://www.reddit.com/r/jellyfin/comments/gaojft/the_path_could_not_be_found_please_ensure_the/
    jellyfin.enable = true;
  };

  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 80 443 22067 ];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 8000; to = 9010; }
    ];
  };
  
  virtualisation.docker.enable = true;

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

    uinput.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.server = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" "input" "uinput" ];
    # packages = with pkgs; [];
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
    openvpn
    ranger
    evtest
    pamixer
    brightnessctl
    acct

    # Other
    docker
    docker-compose
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
