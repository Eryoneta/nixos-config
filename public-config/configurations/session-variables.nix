{ ... }@args: with args.config-utils; { # (Setup Module)

  # Session variables
  config.modules."session-variables" = {
    tags = [ "default-setup" ];
    setup = {
      home = { config, ... }: { # (Home-Manager Module)

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
