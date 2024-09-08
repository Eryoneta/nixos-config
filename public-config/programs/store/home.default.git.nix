{ config, pkgs-bundle, user, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    config = {

      # Git: File Version
      programs.git = {
        enable = mkDefault true;
        package = mkDefault pkgs-bundle.stable.git;
      };

    };
  }
