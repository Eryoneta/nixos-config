{ config, user, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # User
  config.modules."user" = {
    tags = [ "core-setup" ];
    attr.profileIcon = username: (config.modules."configuration".attr.mkSymlink {
      # Searches for "resources/profiles/USERNAME/.face.icon"
      private-resource = "profiles/${username}/.face.icon";
      public-resource = "profiles/${username}/.face.icon";
    });
    attr.defaultPassword = "nixos"; # The default password
    attr.hashedPasswordFilePath = hashedFilePath: ( # Uses a hashedFile if it exists
      config.modules."configuration".attr.mkSecret {
        private = hashedFilePath;
      }
    );
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
