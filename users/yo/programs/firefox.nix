{ config, pkgs-bundle, user, ... }:
  let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {

    # Firefox
    programs.firefox = {
      enable = true;
      package = pkgs-bundle.stable.firefox; # Pacote: Stable, AutoUpgrade
    };

  }
