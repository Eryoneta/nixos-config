{ config, host, ... }: {

  imports = [
    ../default/configuration.nix # Default
    ./hardware-configuration.nix # Scan de hardware
    ./hardware-fixes.nix # Hardware fixes
    ./programs.nix # Programs
  ];

  # LiCo
  config = {

    # Autologin
    services.displayManager.autoLogin.enable = true;

  };

}
