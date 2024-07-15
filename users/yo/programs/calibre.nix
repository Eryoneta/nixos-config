{ config, pkgs-bundle, user, ... }:
  let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    home = {

      # Pacote: Unstable, Manual Upgrade
      packages = with pkgs-bundle.unstable-fixed; [ calibre ];

      # Dotfiles
      file.".config/calibre".source = mkOutOfStoreSymlink "${user.dotFolder}/calibre/.config/calibre";

    };
  }
