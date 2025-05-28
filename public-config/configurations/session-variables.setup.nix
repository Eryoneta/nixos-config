{ config, ... }@args: with args.config-utils; { # (Setup Module)

  config.modules."basic-variables" = {

    # Configuration
    tags = [ "basic-setup" ];

    setup = {
      home = { config, ... }: { # (Home-Manager Module)
        config = {

          # Variables
          home.sessionVariables = {
            "EDITOR" = (utils.mkDefault) "kwrite"; # Default Text Editor
            "DEFAULT_BROWSER" = (utils.mkDefault) "${config.programs.firefox.package}/bin/firefox"; # Default Browser
            "MOZ_ENABLE_WAYLAND" = 0; # Disable wayland for Firefox
            # Note: Bookmark dragging does NOT work under submenus! The menu keeps disappearing! Unusable!
            # TODO: (Firefox) Enable wayland for Firefox when it works
          };

        };
      };
    };
  };

  config.modules."yo-variables" = {

    # Configuration
    tags = [ "yo" ];
    attr.firefox-devedition.packageChannel = config.modules."firefox-devedition".attr.packageChannel;

    setup = { attr }: {
      home = { # (Home-Manager Module)
        config = {

          # Variables
          home.sessionVariables = {
            "DEFAULT_BROWSER" = with attr.firefox-devedition; (
              "${packageChannel.firefox-devedition}/bin/firefox" # Default Browser
            );
          };

        };
      };
    };
  };

  config.modules."eryoneta-variables" = {

    # Configuration
    tags = [ "eryoneta" ];

    setup = {
      home = { # (Home-Manager Module)
        config = {

          # Variables
          home.sessionVariables = {};

        };
      };
    };
  };

}
