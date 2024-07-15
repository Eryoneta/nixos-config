{ config, pkgs-bundle, user, ... }:
  let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {

    # Git
    programs.git = {
      enable = true;
      package = pkgs-bundle.stable.git; # Pacote: Stable, AutoUpgrade
    };

  }
