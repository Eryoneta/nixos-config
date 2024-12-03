{ lib, config, host, pkgs-bundle, ... }@args: with args.config-utils; {

  options = {
    profile.programs.samba = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.samba; (lib.mkIf (options.enabled) {

    # Samba: File sharing
    services.samba = {
      enable = options.enabled;
      package = (options.packageChannel).samba; # Stable channel
      openFirewall = true; # Open firewall
      securityType = "user"; # Require login
      shares = {
        # Options: https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
        "Público" = {
          "comment" = "${host.user.name}'s shared files";
          # Browsing
          "directory" = config.home-manager.users.${host.user.username}.xdg.userDirs.publicShare;
          "browseable" = "yes"; # Can see
          "read only" = "no"; # Can write
          "hide dot files" = "no"; # Can see dotfiles
          "force user" = host.user.username; # Act as if is main user
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
    services.samba-wsdd = {
      enable = options.enabled;
      openFirewall = config.services.samba.openFirewall;
    };

    # At Hosts/Default/Security
    #networking.firewall.enable = true;
    #networking.firewall.allowPing = true;

    # TODO: (Samba) Fix Dolphin not finding Samba shares

  });

}