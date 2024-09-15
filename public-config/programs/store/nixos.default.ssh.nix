{ lib, pkgs-bundle, ... }: 
  let
    mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # SSH: Secure connection
      programs.ssh = { # Its always enabled
        package = mkDefault pkgs-bundle.stable.openssh;
        startAgent = mkDefault true; # SSH Agent
      };

    };
  }
