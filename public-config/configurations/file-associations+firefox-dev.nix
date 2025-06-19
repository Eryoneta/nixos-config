{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # File associations for Firefox-Dev
  config.modules."file-associations+firefox-dev" = {
    tags = [ "personal-setup" ];
    attr.associateDefault = config.modules."file-associations".attr.associateDefault;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # XDG Mime Apps
        config.xdg.mimeApps.defaultApplications = (utils.mkMerge [

          # Firefox Developer-Edition
          (attr.associateDefault "firefox-devedition.desktop" [
            "default-web-browser"
            "text/html"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/about"
            "x-scheme-handler/unknown"
          ])

        ]);

      };
    };
  };

}
