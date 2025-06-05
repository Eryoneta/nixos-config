{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Samba: File sharing
  config.modules."samba" = {
    enable = false; # Not used for now
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { config, host, ... }: { # (NixOS Module)

        # Configuration
        config.services.samba = {
          enable = true;
          package = (attr.packageChannel).samba;
          openFirewall = true; # Open firewall
          securityType = "user"; # Require login
          shares = {
            # Options: https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
            "Público" = {
              "comment" = "${host.userDev.name}'s shared files";
              # Browsing
              "directory" = config.home-manager.users.${host.userDev.username}.xdg.userDirs.publicShare;
              "browseable" = "yes"; # Can see
              "read only" = "no"; # Can write
              "hide dot files" = "no"; # Can see dotfiles
              "force user" = host.userDev.username; # Act as if is main user
              "force group" = "users"; # Act as if from "users"
              # Security
              "server role" = "standalone"; # Is a single server with a user
              "security" = "user"; # Requires login
              "guest ok" = "no"; # No guest allowed
              "usershare allow guests" = "no"; # No guest allowed
              "usershare owner only" = "yes"; # Do not share folders from other users
              "deadtime" = 30; # Disconnect after 30 minutes
              "load printers" = "no"; # Do not load shared printers
            };
          };
        };

        # Samba WSDD: Host discovery
        config.services.samba-wsdd = {
          enable = true;
          openFirewall = config.services.samba.openFirewall;
        };

        # At "security.nix"
        #networking.firewall.enable = true;
        #networking.firewall.allowPing = true;

        # TODO: (Samba) Fix Dolphin not finding Samba shares

      };
    };
  };

}
