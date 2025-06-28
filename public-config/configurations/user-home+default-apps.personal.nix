{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Default apps
  config.modules."user-home+default-apps.personal" = {
    tags = config.modules."user-home.personal".tags;
    attr.associateDefault = config.modules."user-home+default-apps".attr.associateDefault;
    attr.includedModules = config.includedModules;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Assert the presence of the default apps
        config.assertions = [
          {
            assertion = (attr.includedModules."firefox-devedition" or false);
            message = "The configuration of default apps requires the module \"firefox-devedition\" to be included";
          }
        ];

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
