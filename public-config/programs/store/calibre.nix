{ config, pkgs-bundle, config-domain, ... }:
  let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    config = {

      # Calibre: Biblioteca de livros
      home = {
        packages = with pkgs-bundle.unstable-fixed; [ calibre ]; # Pacote: Unstable, Manual Upgrade
        file.".config/calibre".source = mkOutOfStoreSymlink "${config-domain.private.dotfiles}/calibre/.config/calibre";
      };

    };
  }
