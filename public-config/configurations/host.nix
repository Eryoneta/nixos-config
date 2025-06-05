{ ... }@args: with args.config-utils; { # (Setup Module)

  # Host
  config.modules."host" = {
    tags = [ "core-setup" ];
    setup = {
      nixos = { host, ... }: { # (NixOS Module)

        # Hostname
        config.networking.hostName = host.name;

        # Network access
        config.networking.networkmanager.enable = (utils.mkDefault) true;

        # DHCP
        config.networking.useDHCP = (utils.mkDefault) true;

        # Time zone
        config.time.timeZone = (utils.mkDefault) "America/Sao_Paulo";

        # Locale
        config.i18n = (
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

        # Nix Packages
        config.nixpkgs.hostPlatform = host.system.architecture;

        # Start version
        config.system.stateVersion = "${host.system.stateVersion}"; # NixOS start version. (Default options)

      };
    };
  };

}
