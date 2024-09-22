{ ... }@args: with args.config-utils; {

  imports = [
    ../default/configuration.nix # Default
    ./hardware-configuration.nix # Scan de hardware
    ./hardware-fixes.nix # Hardware fixes
  ];

  config = {

    # Autologin
    services.displayManager.autoLogin.enable = true;

  };

}
