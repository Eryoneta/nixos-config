{ host, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # Hostname
      networking.hostName = host.name;

      # Internet
      networking.networkmanager.enable = mkDefault true;

      # Time zone
      time.timeZone = mkDefault "America/Sao_Paulo";

      # Locale
      i18n.defaultLocale = mkDefault "pt_BR.UTF-8";
      i18n.extraLocaleSettings = mkDefault {
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

    };
}
