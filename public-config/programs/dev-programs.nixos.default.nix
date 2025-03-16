{ lib, pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # MySQL: MySQL Database v8.0
    services.mysql = {
      enable = false;
      package = (pkgs-bundle.stable).mysql80;
    };

  };
}
