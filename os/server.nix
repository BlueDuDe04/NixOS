{ pkgs, ... }: {

  networking.hostName = "Server";

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  services = {
    nginx = {
      enable = true;

      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."192.168.0.40" =  {
        locations."/" = {
          proxyPass = "http://127.0.0.1";
          proxyWebsockets = true;
        };
      };
    };

    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };

    samba-wsdd = {
      # make shares visible for windows 10 clients
      enable = true;
      openFirewall = true;
    };

    samba = {
      enable = true; 

      shares = {
        Jellyfin = {
          path = "/media";
          "read only" = false;
          browseable = "yes";
          "guest ok" = "yes";
          comment = "Jellyfin Media";
        };

        Gameyfin = {
          path = "/var/lib/gameyfin";
          # "read only" = true;
          browseable = "yes";
          "guest ok" = "yes";
          comment = "Gameyfin Games";
        };
      };
    };

    # Set: <insecureSkipHostcheck>true</insecureSkipHostcheck> in <gui>...</gui>
    # In: /var/lib/syncthing/.config/syncthing/config.xml
    # https://docs.syncthing.net/users/faq.html#why-do-i-get-host-check-error-in-the-gui-api
    syncthing = {
      enable = true;
      guiAddress = "192.168.0.40:8384";
    };

    # Set: sudo setfacl -m u:jellyfin:rx /media/*
    # https://www.reddit.com/r/jellyfin/comments/gaojft/the_path_could_not_be_found_please_ensure_the/
    jellyfin.enable = true;
  };

  systemd.services.Gameyfin = {
    serviceConfig = {
      WorkingDirectory = "/var/lib/gameyfin";
      ExecStart = "${pkgs.jdk21}/bin/java -jar gameyfin-1.4.4.jar";
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
}
