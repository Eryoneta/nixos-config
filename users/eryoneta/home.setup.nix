{ ... }@args: with args.config-utils; { # (Setup Module)

  # Imports
  imports = [ ./default.setup.nix ];
  config.includeTags = [ "default-user" "eryoneta" ];

  config.modules."eryoneta-user" = {

    # Configuration
    tags = [ "eryoneta" ];

    setup = {
      home = { config, ... }: { # (Home-Manager Module)
        config = {

          # Variables
          home.sessionVariables = {
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
