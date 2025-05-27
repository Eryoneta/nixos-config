{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # Imports
  imports = [ ./default.setup.nix ];
  config.enabledTags = [ "default-user" "yo" ];

  config.modules."yo-user" = {

    # Configuration
    tags = [ "yo" ];
    attr.firefox-devedition.packageChannel = config.modules."firefox-devedition".attr.packageChannel;

    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)
        config = {

          # Username
          home.username = args.user.username;

          # Variables
          home.sessionVariables = {
            "DEFAULT_BROWSER" = with attr.firefox-devedition; (
              "${packageChannel.firefox-devedition}/bin/firefox" # Default Browser
            );
            "MOZ_ENABLE_WAYLAND" = 0; # Disable wayland for Firefox
            # Note: Bookmark dragging does NOT work under submenus! The menu keeps disappearing! Unusable!
            # TODO: (Firefox) Enable wayland for Firefox when it works
          };

          # Profile
          home.file.".face.icon" = with args.config-domain; {
            # Check for "./private-config/resources"
            enable = (utils.pathExists private.resources);
            source = with private; (
              "${resources}/profiles/${config.home.username}/.face.icon"
            );
          };

        };
      };
    };
  };
}
