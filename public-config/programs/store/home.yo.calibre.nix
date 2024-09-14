{ config, pkgs-bundle, config-domain, ... }:
  let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    config = {

      # Calibre: E-Book manager
      home = {
        packages = with pkgs-bundle.unstable-fixed; [ calibre ];
      };

      home.file.".config/calibre".source = (mkOutOfStoreSymlink "${config-domain.private.dotfiles}/calibre/.config/calibre");

    };
  }
