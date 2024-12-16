{ user, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {
    
  imports = [
    ../default/home.nix # Default
    ./stylix.nix
  ];

  config = {
    
    # Variables
    home.sessionVariables = {
      "DEFAULT_BROWSER" = "${pkgs-bundle.unstable.firefox-devedition}/bin/firefox-devedition"; # Default Browser
      "MOZ_ENABLE_WAYLAND" = 0; # Disable wayland for Firefox
      # Note: Bookmark dragging does NOT work under submenus! The menu keeps disappearing! Unusable!
      # TODO: (Firefox) Enable wayland for Firefox when it works
    };

    # XDG Mime Apps
    xdg.mimeApps = {
      defaultApplications = (
        let
          defaultBrowser = [ "firefox-devedition.desktop" ];
          defaultTextEditor = [ "org.kde.kwrite.desktop" ];
          defaultLightCodeEditor = [ "org.kde.kate.desktop" ];
        in {
          # Web
          "default-web-browser" = defaultBrowser;
          "text/html" = defaultBrowser;
          "x-scheme-handler/http" = defaultBrowser;
          "x-scheme-handler/https" = defaultBrowser;
          "x-scheme-handler/about" = defaultBrowser;
          "x-scheme-handler/unknown" = defaultBrowser;
          # Text
          "text/plain" = defaultTextEditor;
          "text/markdown" = defaultTextEditor;
          # Code
          "application/json" = defaultLightCodeEditor;
          "application/x-yaml" = defaultLightCodeEditor;
          "application/x-docbook+xml" = defaultLightCodeEditor;
          "text/x-cmake" = defaultLightCodeEditor;
        }
      );
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
