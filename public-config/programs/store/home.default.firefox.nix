{ config, pkgs-bundle, user, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    config = {

      # Firefox: Browser
      programs.firefox = {
        enable = mkDefault true;
        package = mkDefault pkgs-bundle.stable.firefox;
      };

    };
  }
