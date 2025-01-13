{ user, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {
    
  imports = [
    ../default/home.nix # Default
    ./stylix.nix
    ./xdg-mime-apps.nix
  ];

  config = {
    
    # Variables
    home.sessionVariables = {
      "DEFAULT_BROWSER" = "${pkgs-bundle.unstable.firefox-devedition}/bin/firefox-devedition"; # Default Browser
      "MOZ_ENABLE_WAYLAND" = 0; # Disable wayland for Firefox
      # Note: Bookmark dragging does NOT work under submenus! The menu keeps disappearing! Unusable!
      # TODO: (Firefox) Enable wayland for Firefox when it works
    };

    # Profile
    home.file.".face.icon" = with config-domain; {
      # Check for "./private-config/resources"
      enable = (utils.pathExists private.resources);
      source = with private; (
        "${resources}/profiles/${user.username}/.face.icon"
      );
    };

  };

}
