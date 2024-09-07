{ config, pkgs-bundle, user, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    config = {

      # SSH: Secure connection
      programs.ssh = {
        enable = mkDefault true;
        package = mkDefault pkgs-bundle.stable.openssh;
      };
      services.ssh-agent.enable = mkDefault true;

    };
  }
