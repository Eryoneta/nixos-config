{ pkgs, ... }@args: with args.config-utils; {
  config.setup.modules."mysql" = {

    # Configuration
    enabled = true;
    tags = [ "development" "development-database" ];
    attributes.packageChannel = pkgs;

    # NixOS
    nixos = { attributes }: {

      # MySQL: MySQL Database v8.0
      services.mysql = {
        enable = true;
        package = attributes.packageChannel.mysql80;
      };

    };

  };
}