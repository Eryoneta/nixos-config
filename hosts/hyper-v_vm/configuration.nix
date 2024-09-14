{ ... }: {

  imports = [
    ../default/configuration.nix # Default
    ./hardware-configuration.nix # Scan de hardware
    ./hardware-fixes.nix # Hardware fixes
  ];

  # Hyper-V_VM
  config = {

    # Autologin
    services.displayManager.autoLogin.enable = true;

  };

}
