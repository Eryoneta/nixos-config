{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."default-variables" = {

    tags = [ "default-user" ];

    setup = {
      home = { config, ... }: { # (Home-Manager Module)
        config = {

          # Variables
          home.sessionVariables = {
            "EDITOR" = (utils.mkDefault) "kwrite"; # Default Text Editor
            "DEFAULT_BROWSER" = (utils.mkDefault) "${config.programs.firefox.package}/bin/firefox"; # Default Browser
          };

        };
      };
    };
  };
}
