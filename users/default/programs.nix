{ config, pkgs-bundle, user, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # Pacotes
      home.packages = []
      # Pacotes: Stable, AutoUpgrade
      ++ (with pkgs-bundle.stable; [
        
      ])
      # Pacotes: Unstable, AutoUpgrade
      ++ (with pkgs-bundle.unstable; [

      ])
      # Pacotes: Unstable, Manual Upgrade
      ++ (with pkgs-bundle.unstable-fixed; [

      ]);

      programs.ssh = {
        enable = mkDefault true;
        package = pkgs-bundle.stable.openssh;
      };
      services.ssh-agent.enable = true;

    };
  }
