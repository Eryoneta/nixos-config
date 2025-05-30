{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # Session variables
  config.modules."session-variables" = {
    tags = [ "basic-setup" ];
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

  # Yo variables
  config.modules."session-variables+yo" = {
    attr.firefox-devedition.packageChannel = config.modules."firefox-devedition".attr.packageChannel;
    tags = [ "yo" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Variables
        config.home.sessionVariables = {
          "DEFAULT_BROWSER" = with attr.firefox-devedition; (
            "${packageChannel.firefox-devedition}/bin/firefox" # Default Browser
          );
        };

      };
    };
  };

  # Eryoneta variables
  config.modules."session-variables+eryoneta" = {
    tags = [ "eryoneta" ];
    setup = {
      home = { # (Home-Manager Module)

        # Variables
        config.home.sessionVariables = {};

      };
    };
  };

}
