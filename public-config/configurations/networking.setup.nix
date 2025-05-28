{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."basic-networking" = {

    # Configuration
    tags = [ "basic-setup" ];

    setup = {
      nixos = { host, ... }: { # (NixOS Module)
        config = {

          # Hostname
          networking.hostName = host.name;

          # Network access
          networking.networkmanager.enable = (utils.mkDefault) true;

          # Time zone
          time.timeZone = (utils.mkDefault) "America/Sao_Paulo";

          # Locale
          i18n = (
            let
              locale = "pt_BR.UTF-8";
            in {
              defaultLocale = (utils.mkDefault) locale;
              extraLocaleSettings = (utils.mkDefault) {
                "LC_ADDRESS" = locale;
                "LC_IDENTIFICATION" = locale;
                "LC_MEASUREMENT" = locale;
                "LC_MONETARY" = locale;
                "LC_NAME" = locale;
                "LC_NUMERIC" = locale;
                "LC_PAPER" = locale;
                "LC_TELEPHONE" = locale;
                "LC_TIME" = locale;
              };
            }
          );

        };
      };
    };
  };
}
