{ config, pkgs-bundle, user, ... }:
  let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  in {
    config = {

      # SSH: Agente SSH para conexão segura
      programs.ssh = {
        enable = true;
        package = pkgs-bundle.stable.openssh;
      };
      services.ssh-agent.enable = true;

    };
  }
