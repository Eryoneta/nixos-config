{ pkgs-bundle, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
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
