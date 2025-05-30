{ ... }@args: with args.config-utils; { # (Setup Module)

  # Core setup
  config.modules."core-setup" = {
    tags = [ "core-setup" ];
    setup = {
      nixos = { host, ... }: { # (NixOS Module)
        config = {

          # Hostname
          networking.hostName = host.name;

          # Network access
          networking.networkmanager.enable = (utils.mkDefault) true;

          # DHCP
          networking.useDHCP = (utils.mkDefault) true;

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

          # Nix Packages
          nixpkgs.hostPlatform = host.system.architecture;

          # Start version
          system.stateVersion = "${host.system.stateVersion}"; # NixOS start version. (Default options)

        };
      };
      home = { config, user, ... }: { # (Home-Manager Module)

        # Home-Manager
        config.home = {

          # Username
          username = user.username;

          # User home folder
          homeDirectory = "/home/${config.home.username}"; # Home should always be at "/home"

          # Start version
          stateVersion = "${user.host.system.stateVersion}"; # Home-Manager start version. (Default options)
          # Note: As Home-Manager is always installed with NixOS here, the start version should be the same

        };

        # AutoInstall Home-Manager CLI
        # Only works for standalone!
        # As a module, it needs to be included at "environment.systemPackages"
        config.programs.home-manager.enable = true;

        # Home-Manager News
        # A necessary file to run "home-manager news"
        config.xdg.configFile."home-manager/home.nix" = {
          text = ''
            {
              home.username = "${config.home.username}";
              home.homeDirectory = "${config.home.homeDirectory}";
              home.stateVersion = "${config.home.stateVersion}";
            }
          '';
        };

      };
    };
  };

}
