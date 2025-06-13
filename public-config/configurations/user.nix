{ user, host, config-domain, ... }@args: with args.config-utils; { # (Setup Module)

  # User
  config.modules."user" = {
    tags = [ "core-setup" ];
    attr.profileIcon = username: (with config-domain; { # Requires "resources/profiles/USERNAME/.face.icon" to exist!
      # Check for "./private-config/resources"
      enable = (utils.pathExists private.resources);
      source = (
        "${private.resources}/profiles/${username}/.face.icon"
      );
    });
    attr.defaultPassword = username: hashedFilePath: (with config-domain; ( # Sets a default password if there is no hashedFile
      # Check for "./private-config/secrets"
      utils.mkIf (!(utils.pathExists private.secrets) || hashedFilePath == null || host.system.virtualDrive) (
        "nixos"
      )
    ));
    attr.hashedPasswordFilePath = username: hashedFilePath: (with config-domain; ( # Uses a hashedFile if it exists
      # Check for "./private-config/secrets"
      utils.mkIf ((utils.pathExists private.secrets) && hashedFilePath != null && !host.system.virtualDrive) (
        hashedFilePath
      )
    ));
    setup = {
      home = { config, ... }: { # (Home-Manager Module)

        # Home-Manager
        config.home = {

          # Username
          username = user.username;

          # User home folder
          homeDirectory = "/home/${config.home.username}"; # Home should always be at "/home"

          # Start version
          stateVersion = "${user.host.system.stateVersion}"; # Home-Manager start version. (Default options)
          # Note: As Home-Manager is always installed with NixOS here, the start version should be the same

        };

        # AutoInstall Home-Manager CLI
        # Only works for standalone!
        # As a module, it needs to be included at "config.environment.systemPackages"
        config.programs.home-manager.enable = true;

        # Home-Manager News
        # A necessary file to run "home-manager news"
        config.xdg.configFile."home-manager/home.nix" = {
          text = ''
            {
              home.username = "${config.home.username}";
              home.homeDirectory = "${config.home.homeDirectory}";
              home.stateVersion = "${config.home.stateVersion}";
            }
          '';
        };

      };
    };
  };

}
