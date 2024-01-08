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
          proxyPass = "http://127.0.0.1:8384";
          proxyWebsockets = true;
        };
      };

      virtualHosts."192.168.0.10" =  {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
        };
      };

      virtualHosts."192.168.0.28" =  {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
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

  systemd.services.Gameyfin = {
    serviceConfig.ExecStart = "${pkgs.jdk21}/bin/java -jar /var/lib/gameyfin/gameyfin-1.4.4.jar";
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
