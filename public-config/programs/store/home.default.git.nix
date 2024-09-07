{ config, pkgs-bundle, user, ... }:
  let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    config = {

      # Git: Versionador de arquivos
      programs.git = {
        enable = true;
        package = pkgs-bundle.stable.git; # Pacote: Stable, AutoUpgrade
      };

    };
  }
