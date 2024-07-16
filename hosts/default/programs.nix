{ config, host, pkgs-bundle, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # Pacotes
      nixpkgs.config.allowUnfree = true; # Precaução. Mas pkgs não é usado
      environment.systemPackages = with pkgs-bundle.stable; [
        gparted       # Gerencia partições
        neofetch      # Exibe informações do sistema (Deprecated)
        home-manager  # Gerencia home
        git           # Versionamento
      ];

      # OpenSSH (Server SSH)
      services.openssh.enable = mkDefault false;
      services.openssh = {
        ports = [ 22 ];
        openFirewall = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };

    };
}
