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
          defaultBrowser = "firefox-devedition.desktop";
          defaultTextEditor = "org.kde.kwrite.desktop";
          defaultLightCodeEditor = "org.kde.kate.desktop";
          defaultMediaPlayer = "mpv.desktop";
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
          # Media
          # As defined by "KDE Plasma" in ~/config/mimeapps.list
          # Note: This is necessary as "UMPV" is INSISTENT in being the default, for some reason
          #   Note: "UMPV" is like "MPV", but all new medias are added into a playlist, instead of a new instance
          "application/x-matroska" = defaultMediaPlayer;
          "audio/aac" = defaultMediaPlayer;
          "audio/mp4" = defaultMediaPlayer;
          "audio/mpeg" = defaultMediaPlayer;
          "audio/mpegurl" = defaultMediaPlayer;
          "audio/ogg" = defaultMediaPlayer;
          "audio/vnd.rn-realaudio" = defaultMediaPlayer;
          "audio/vorbis" = defaultMediaPlayer;
          "audio/x-flac" = defaultMediaPlayer;
          "audio/x-mp3" = defaultMediaPlayer;
          "audio/x-mpegurl" = defaultMediaPlayer;
          "audio/x-ms-wma" = defaultMediaPlayer;
          "audio/x-musepack" = defaultMediaPlayer;
          "audio/x-oggflac" = defaultMediaPlayer;
          "audio/x-pn-realaudio" = defaultMediaPlayer;
          "audio/x-scpls" = defaultMediaPlayer;
          "audio/x-vorbis" = defaultMediaPlayer;
          "audio/x-vorbis+ogg" = defaultMediaPlayer;
          "audio/x-wav" = defaultMediaPlayer;
          "video/3gp" = defaultMediaPlayer;
          "video/3gpp" = defaultMediaPlayer;
          "video/3gpp2" = defaultMediaPlayer;
          "video/avi" = defaultMediaPlayer;
          "video/divx" = defaultMediaPlayer;
          "video/dv" = defaultMediaPlayer;
          "video/fli" = defaultMediaPlayer;
          "video/flv" = defaultMediaPlayer;
          "video/mp2t" = defaultMediaPlayer;
          "video/mp4" = defaultMediaPlayer;
          "video/mp4v-es" = defaultMediaPlayer;
          "video/mpeg" = defaultMediaPlayer;
          "video/msvideo" = defaultMediaPlayer;
          "video/ogg" = defaultMediaPlayer;
          "video/quicktime" = defaultMediaPlayer;
          "video/vnd.divx" = defaultMediaPlayer;
          "video/vnd.mpegurl" = defaultMediaPlayer;
          "video/vnd.rn-realvideo" = defaultMediaPlayer;
          "video/webm" = defaultMediaPlayer;
          "video/x-avi" = defaultMediaPlayer;
          "video/x-flv" = defaultMediaPlayer;
          "video/x-m4v" = defaultMediaPlayer;
          "video/x-matroska" = defaultMediaPlayer;
          "video/x-mpeg2" = defaultMediaPlayer;
          "video/x-ms-asf" = defaultMediaPlayer;
          "video/x-ms-wmv" = defaultMediaPlayer;
          "video/x-ms-wmx" = defaultMediaPlayer;
          "video/x-msvideo" = defaultMediaPlayer;
          "video/x-ogm" = defaultMediaPlayer;
          "video/x-ogm+ogg" = defaultMediaPlayer;
          "video/x-theora" = defaultMediaPlayer;
          "video/x-theora+ogg" = defaultMediaPlayer;
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
