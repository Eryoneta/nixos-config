{ config, ... }@args: with args.config-utils; {
  config = {
    
    # XDG Mime Apps
    xdg.mime.enable = true;
    xdg.mimeApps = {
      enable = true;
      defaultApplications = (
        let
          defaultBrowser = [ "firefox.desktop" ];
          defaultTextEditor = [ "org.kde.kwrite.desktop" ];
        in {
          # Web
          "default-web-browser" = mkDefault defaultBrowser;
          "text/html" = mkDefault defaultBrowser;
          "x-scheme-handler/http" = mkDefault defaultBrowser;
          "x-scheme-handler/https" = mkDefault defaultBrowser;
          "x-scheme-handler/about" = mkDefault defaultBrowser;
          "x-scheme-handler/unknown" = mkDefault defaultBrowser;
          # Text
          "text/plain" = mkDefault defaultTextEditor;
          "text/markdown" = mkDefault defaultTextEditor;
          "application/json" = mkDefault defaultTextEditor;
          "application/x-yaml" = mkDefault defaultTextEditor;
          "application/x-docbook+xml" = mkDefault defaultTextEditor;
          "text/x-cmake" = mkDefault defaultTextEditor;
        }
      );
    };

  };
}
