{ pkgs-bundle, ... }@args: with args.config-utils; {
    
  imports = [
    ../default/home.nix # Default
    ./stylix.nix
  ];

  config = {
    
    # Variables
    home.sessionVariables = {
      DEFAULT_BROWSER = "${pkgs-bundle.unstable.firefox-devedition}/bin/firefox-devedition"; # Default Browser
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

  };

}
