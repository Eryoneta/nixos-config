{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."default-user" = {

    tags = [ "core" "basic" "default-user" ];

    setup.home = {config, ...}: { # (Home-Manager Module)
      config = {

        # Home-Manager
        home = {

          # User home folder
          homeDirectory = "/home/${config.home.username}"; # Home should always be at "/home"

          # Start version
          stateVersion = "${args.user.host.system.stateVersion}"; # Home-Manager start version. (Default options)
          # Note: As Home-Manager is always installed with NixOS here, the start version should be the same

        };

        # AutoInstall Home-Manager CLI
        # Only works for standalone!
        # As a module, it needs to be included at "environment.systemPackages"
        programs.home-manager.enable = true;

        # Home-Manager News
        # A necessary file to run "home-manager news"
        xdg.configFile."home-manager/home.nix" = {
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
