{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # Default apps
  config.modules."user-home+default-apps" = {
    tags = config.modules."user-home".tags;
    attr.associateDefault = app: extensions: (utils.pipe extensions [

      # Invert the association: Each extension points to the app
      (x: builtins.map (extension: {
        "${extension}" = app;
      }) x)

      # Merge all sets into a single set
      (x: builtins.foldl' (x: y: (x // y)) {} x)

    ]);
    attr.associateDefaultDefault = app: extensions: (
      utils.pipe (config.modules."user-home+default-apps".attr.associateDefault app extensions) [

        # Set as default
        (x: builtins.mapAttrs (extension: app: (
          (utils.mkDefault) app
        )) x)

      ]
    );
    attr.includedModules = config.includedModules;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Assert the presence of the default apps
        config.assertions = [
          {
            assertion = (attr.includedModules."firefox" or false);
            message = "The configuration of default apps requires the module \"firefox\" to be included";
          }
          {
            assertion = (attr.includedModules."kwrite" or false);
            message = "The configuration of default apps requires the module \"kwrite\" to be included";
          }
          {
            assertion = (attr.includedModules."kate" or false);
            message = "The configuration of default apps requires the module \"kate\" to be included";
          }
          {
            assertion = (attr.includedModules."libreoffice" or false);
            message = "The configuration of default apps requires the module \"libreoffice\" to be included";
          }
          {
            assertion = (attr.includedModules."mpv" or false);
            message = "The configuration of default apps requires the module \"mpv\" to be included";
          }
        ];

        # XDG Mime Apps
        config.xdg.mime.enable = true;
        config.xdg.mimeApps = {
          enable = true;
          defaultApplications = (utils.mkMerge [

            # Firefox
            (attr.associateDefaultDefault "firefox.desktop" [
              "default-web-browser"
              "text/html"
              "x-scheme-handler/http"
              "x-scheme-handler/https"
              "x-scheme-handler/about"
              "x-scheme-handler/unknown"
            ])

            # KWrite
            (attr.associateDefaultDefault "org.kde.kwrite.desktop" [
              "text/plain"
              "text/markdown"
            ])

            # Kate
            (attr.associateDefaultDefault "org.kde.kate.desktop" [
              "application/json"
              "application/x-yaml"
              "application/x-docbook+xml"
              "text/x-cmake"
            ])

            # LibreOffice Writer
            (attr.associateDefaultDefault "writer.desktop" [
              # As defined by "writer.desktop"
              "application/clarisworks"
              "application/docbook+xml"
              "application/macwriteii"
              "application/msword"
              "application/prs.plucker"
              "application/rtf"
              "application/vnd.apple.pages"
              "application/vnd.lotus-wordpro"
              "application/vnd.ms-word"
              "application/vnd.ms-word.document.macroEnabled.12"
              "application/vnd.ms-word.template.macroEnabled.12"
              "application/vnd.ms-works"
              "application/vnd.oasis.opendocument.text"
              "application/vnd.oasis.opendocument.text-flat-xml"
              "application/vnd.oasis.opendocument.text-master"
              "application/vnd.oasis.opendocument.text-master-template"
              "application/vnd.oasis.opendocument.text-template"
              "application/vnd.oasis.opendocument.text-web"
              "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
              "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
              "application/vnd.palm"
              "application/vnd.stardivision.writer-global"
              "application/vnd.stardivision.writer-global"
              "application/vnd.sun.xml.writer"
              "application/vnd.sun.xml.writer.global"
              "application/vnd.sun.xml.writer.template"
              "application/vnd.wordperfect"
              "application/wordperfect"
              "application/x-abiword"
              "application/x-aportisdoc"
              "application/x-doc"
              "application/x-extension-txt"
              "application/x-fictionbook+xml"
              "application/x-hwp"
              "application/x-iwork-pages-sffpages"
              "application/x-mswrite"
              "application/x-pocket-word"
              "application/x-sony-bbeb"
              "application/x-starwriter"
              "application/x-starwriter-global"
              "application/x-t602"
              "text/rtf"
            ])

            # MPV
            (attr.associateDefaultDefault "mpv.desktop" [
              # As defined by "KDE Plasma" in ~/config/mimeapps.list
              # Note: This is necessary as "UMPV" is INSISTENT in being the default, for some reason
              #   Extra note: "UMPV" is like "MPV", but all new medias are added into a playlist, instead of a new instance
              "application/x-matroska"
              "audio/aac"
              "audio/mp4"
              "audio/mpeg"
              "audio/mpegurl"
              "audio/ogg"
              "audio/vnd.rn-realaudio"
              "audio/vnd.wave"
              "audio/vorbis"
              "audio/x-aiff"
              "audio/x-flac"
              "audio/x-matroska"
              "audio/x-mp3"
              "audio/x-mpegurl"
              "audio/x-ms-wma"
              "audio/x-musepack"
              "audio/x-oggflac"
              "audio/x-pn-realaudio"
              "audio/x-scpls"
              "audio/x-vorbis"
              "audio/x-vorbis+ogg"
              "audio/x-wav"
              "video/3gp"
              "video/3gpp"
              "video/3gpp2"
              "video/avi"
              "video/divx"
              "video/dv"
              "video/fli"
              "video/flv"
              "video/mp2t"
              "video/mp4"
              "video/mp4v-es"
              "video/mpeg"
              "video/msvideo"
              "video/ogg"
              "video/quicktime"
              "video/vnd.divx"
              "video/vnd.mpegurl"
              "video/vnd.rn-realvideo"
              "video/webm"
              "video/x-avi"
              "video/x-flv"
              "video/x-m4v"
              "video/x-matroska"
              "video/x-mpeg2"
              "video/x-ms-asf"
              "video/x-ms-wmv"
              "video/x-ms-wmx"
              "video/x-msvideo"
              "video/x-ogm"
              "video/x-ogm+ogg"
              "video/x-theora"
              "video/x-theora+ogg"
            ])

          ]);
        };

      };
    };
  };

}
