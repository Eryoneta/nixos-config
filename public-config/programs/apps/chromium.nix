{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Chromium: Internet browser
  config.modules."chromium" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "default-setup" ];
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Configuration
        config.programs.chromium = {
          enable = true;
          package = (utils.mkDefault) (attr.packageChannel).chromium;

          # Extensions
          extensions = [
            { # UBlock Origin
              id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
            }
          ];

        };

      };
    };
  };

}
