{ config, host, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # Computador na Rede
      networking.hostName = host.name;

      # Internet
      networking.networkmanager.enable = mkDefault true;

      # Proxy
      #networking.proxy.default = "http://user:password@proxy:port/";
      #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Firewall
      networking.firewall.enable = true;
      networking.firewall.allowedTCPPorts = [ ];
      networking.firewall.allowedUDPPorts = [ ];

      # Fuso Horário
      time.timeZone = "America/Sao_Paulo";

      # Localização
      i18n.defaultLocale = "pt_BR.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "pt_BR.UTF-8";
        LC_IDENTIFICATION = "pt_BR.UTF-8";
        LC_MEASUREMENT = "pt_BR.UTF-8";
        LC_MONETARY = "pt_BR.UTF-8";
        LC_NAME = "pt_BR.UTF-8";
        LC_NUMERIC = "pt_BR.UTF-8";
        LC_PAPER = "pt_BR.UTF-8";
        LC_TELEPHONE = "pt_BR.UTF-8";
        LC_TIME = "pt_BR.UTF-8";
      };

      # OpenSSH
      services.openssh = {
        enable = mkDefault false;
        ports = [ 22 ];
        openFirewall = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };

    };
}
