{ config, ... }@args: with args.config-utils; { # (Setup Module)

  imports = [ ./default-file-associations.setup.nix ];

  config.modules."firefox-dev-file-associations" = {

    tags = [ "yo" ];
    attr.associateDefault = config.modules."default-file-associations".attr.associateDefault;

    setup = { attr }: {
      home = { # (Home-Manager Module)
        config = {

          # XDG Mime Apps
          xdg.mimeApps = {
            defaultApplications = (
              (attr.associateDefault "firefox-devedition.desktop" [ # Firefox Developer-Edition
                "default-web-browser"
                "text/html"
                "x-scheme-handler/http"
                "x-scheme-handler/https"
                "x-scheme-handler/about"
                "x-scheme-handler/unknown"
              ])
            );
          };

        };
      };
    };
  };
}
