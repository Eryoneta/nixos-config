{ config, config-domain, ... }@args: with args.config-utils; (
  let
    username = "eryoneta";
  in {

    imports = [
      (import ../default/home.nix username) # Imports default with the usrname. This avoids infinite recursion
    ];

    config = {

      home.username = username;
      
      # Variables
      home.sessionVariables = {
        "MOZ_ENABLE_WAYLAND" = 0; # Disable wayland for Firefox
        # Note: Bookmark dragging does NOT work under submenus! The menu keeps disappearing! Unusable!
        # TODO: (Firefox) Enable wayland for Firefox when it works
      };

      # Profile
      home.file.".face.icon" = with config-domain; {
        # Check for "./private-config/resources"
        enable = (utils.pathExists private.resources);
        source = with private; (
          "${resources}/profiles/${config.home.username}/.face.icon"
        );
      };

    };

  }
)
