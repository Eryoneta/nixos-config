{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Chromium: Internet browser
  config.modules."chromium" = {
    tags = [ "personal-setup" "developer-setup" "work-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
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
