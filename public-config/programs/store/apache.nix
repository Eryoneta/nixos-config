{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Apache: A PHP server
  config.modules."apache" = {
    tags = [ "work-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    attr.rootDir = "/srv/apache";
    setup = { attr }: {
      nixos = { config, ... }: { # (NixOS Module)

        # Configuration
        config.services.httpd = {
          enable = true;
          package = (attr.packageChannel).apacheHttpd;
          enablePHP = true; # Use PHP
          virtualHosts."sandbox" = {
            documentRoot = (attr.rootDir); # The root should contain a "index.php"
            extraConfig = ''
              # Allow configurations to be set from the source code (.htaccess files)
              <Directory "${attr.rootDir}">
                AllowOverride All
              </Directory>
            '';
          };
        };

        # Permissions
        config.systemd.tmpfiles.rules = (
          let
            apacheUser = config.services."httpd".user;
            apacheGroup = config.services."httpd".group;
          in [
            "d ${attr.rootDir} 0774 ${apacheUser} ${apacheGroup}"
            # Note: this allows for it to be accessible by Apache and any user within the group
            "d '${config.services.httpd.logDir}' 0750 ${apacheUser} ${apacheGroup}"
            # Note: Users in the group should be able to see the logs
          ]
        );
        config.networking.firewall.allowedTCPPorts = [ 80 443 ];
      };
      home = { # (Home-Manager Module)
        # Git Configuration
        config.programs.git.settings = {
          "safe" = {
            "directory" = attr.rootDir; # Trust the Git repository inside
          };
        };
      };
    };
  };

}
