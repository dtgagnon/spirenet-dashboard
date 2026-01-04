{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf mkOption mkEnableOption types;
  cfg = config.services.spirenet-dashboard;
in
{
  options.services.spirenet-dashboard = {
    enable = mkEnableOption "SpireNet dashboard service";

    package = mkOption {
      type = types.package;
      description = "The spirenet-dashboard package to use";
    };

    domain = mkOption {
      type = types.str;
      default = "spirenet.link";
      description = "Primary domain to serve the dashboard on";
    };

    tailscale = {
      enable = mkEnableOption "Tailscale Funnel for public access";

      port = mkOption {
        type = types.port;
        default = 443;
        description = "Port to expose via Tailscale Funnel (443 for HTTPS, 80 for HTTP, 8443 for alt-HTTPS)";
      };

      hostname = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Tailscale hostname to serve on (e.g., "slim.aegean-interval.ts.net").
          If null, will be generated from the system hostname.
        '';
      };
    };

    enableTailscaleVhost = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Create a Caddy virtual host for the Tailscale hostname.
        Useful for accessing the dashboard via Tailscale without Funnel.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Ensure Caddy is enabled
    services.caddy.enable = true;

    # Configure Caddy to serve the dashboard
    services.caddy.virtualHosts = {
      # Primary domain
      "${cfg.domain}" = {
        extraConfig = ''
          encode gzip
          root * ${cfg.package}
          file_server
        '';
      };
    } // lib.optionalAttrs cfg.enableTailscaleVhost (
      let
        tailscaleHostname =
          if cfg.tailscale.hostname != null then
            cfg.tailscale.hostname
          else
            "${config.networking.hostName}.ts.net";
      in
      {
        "${tailscaleHostname}" = {
          extraConfig = ''
            encode gzip
            root * ${cfg.package}
            file_server
          '';
        };
      }
    );

    # Tailscale Funnel service
    systemd.services.tailscale-funnel-dashboard = mkIf cfg.tailscale.enable {
      description = "Expose SpireNet dashboard via Tailscale Funnel";
      after = [ "caddy.service" "tailscaled.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.tailscale}/bin/tailscale funnel ${toString cfg.tailscale.port}";
        ExecStop = "${pkgs.tailscale}/bin/tailscale funnel --https=${toString cfg.tailscale.port} off";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };

    # Assertions
    assertions = [
      {
        assertion = cfg.tailscale.enable -> config.services.tailscale.enable;
        message = "Tailscale must be enabled to use spirenet-dashboard.tailscale.enable";
      }
      {
        assertion = cfg.tailscale.enable -> (cfg.tailscale.port == 443 || cfg.tailscale.port == 80 || cfg.tailscale.port == 8443);
        message = "Tailscale Funnel only supports ports 443, 80, and 8443";
      }
    ];
  };
}
