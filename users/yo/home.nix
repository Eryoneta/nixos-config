{ config, user, ... }:
  let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    
    imports = [
      ../default/home.nix # Default
      ./programs.nix # Programas
    ];

    config = {

    };

  }
