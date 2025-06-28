{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Session variables
  config.modules."session-variables" = {
    tags = [ "default-setup" ];
    attr.includedModules = config.includedModules;
    setup = { attr }: {
      nixos = {

        # Variables
        config.environment.sessionVariables = {};

      };
      home = { config, ... }: { # (Home-Manager Module)

        # Assert the presence of the default apps
        config.assertions = [
          {
            assertion = (attr.includedModules."kwrite" or false);
            message = "The configuration of session variables requires the module \"kwrite\" to be included";
          }
          {
            assertion = (attr.includedModules."firefox" or false);
            message = "The configuration of session variables requires the module \"firefox\" to be included";
          }
        ];

        # Variables
        config.home.sessionVariables = {
          "EDITOR" = (utils.mkDefault) "kwrite"; # Default Text Editor
          "DEFAULT_BROWSER" = (utils.mkDefault) "${config.programs.firefox.package}/bin/firefox"; # Default Browser
          "MOZ_ENABLE_WAYLAND" = 0; # Disable wayland for Firefox
          # Note: Bookmark dragging does NOT work under submenus! The menu keeps disappearing! Unusable!
          # TODO: (Firefox) Enable wayland for Firefox when it works
        };

      };
    };
  };

}
