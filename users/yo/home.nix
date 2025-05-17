{ config, ... }@args: with args.config-utils; (
  let
    username = "yo";
  in {

    imports = [
      (import ../default/home.nix username) # Imports default with the usrname. This avoids infinite recursion
      ./stylix.nix
      ./xdg-mime-apps.nix
    ];

    config = {

      home.username = username;
      
      # Variables
      home.sessionVariables = {
        "DEFAULT_BROWSER" = with config.profile.programs.firefox-devedition; (
          "${(options.packageChannel).firefox-devedition}/bin/firefox" # Default Browser
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

  }
)
