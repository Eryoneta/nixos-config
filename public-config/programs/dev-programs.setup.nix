{ pkgs, ... }@args: with args.config-utils; { # Setup Module
  config.modules."mysql" = {

    # Configuration
    enabled = true;
    tags = [ "development" "development-database" ];
    attr.packageChannel = pkgs;

    # NixOS
    setup = { attr }: {
      nixos = { # NixOS Module

        # MySQL: MySQL Database v8.0
        services.mysql = {
          enable = true;
          package = attr.packageChannel.mysql80;
        };

      };
    };

  };
}