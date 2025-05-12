{ ... }@args: with args.config-utils; {
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
          "default-web-browser" = (utils.mkDefault) defaultBrowser;
          "text/html" = (utils.mkDefault) defaultBrowser;
          "x-scheme-handler/http" = (utils.mkDefault) defaultBrowser;
          "x-scheme-handler/https" = (utils.mkDefault) defaultBrowser;
          "x-scheme-handler/about" = (utils.mkDefault) defaultBrowser;
          "x-scheme-handler/unknown" = (utils.mkDefault) defaultBrowser;
          # Text
          "text/plain" = (utils.mkDefault) defaultTextEditor;
          "text/markdown" = (utils.mkDefault) defaultTextEditor;
          "application/json" = (utils.mkDefault) defaultTextEditor;
          "application/x-yaml" = (utils.mkDefault) defaultTextEditor;
          "application/x-docbook+xml" = (utils.mkDefault) defaultTextEditor;
          "text/x-cmake" = (utils.mkDefault) defaultTextEditor;
        }
      );
    };

  };
}
