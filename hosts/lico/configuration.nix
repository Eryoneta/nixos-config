{ config, host, ... }: {
  imports = [
    ./hardware-configuration.nix # Scan de hardware
    ../default/configuration.nix # Defaults
    ./hardware-fixes.nix # Hardware fixes
  ];
  config = {
    # Label da Configuração Atual
    system.nixos.label = "Config_Organization:_With_Defaults"; #[a-zA-Z0-9:_\.-]*

    # Autologin
    services.displayManager = {
      autoLogin.enable = true;
      autoLogin.user = host.user.username;
    };
  };
}
