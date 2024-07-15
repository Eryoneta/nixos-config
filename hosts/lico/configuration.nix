{ config, pkgs-bundle, host, ... }: {
  imports = [
    ./hardware-configuration.nix # Scan de hardware
    ../default/configuration.nix # Defaults
    ./hardware-fixes.nix # Hardware fixes
  ];
  config = {

    # Pacotes
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs-bundle; [
      #
    ];

    # Autologin
    services.displayManager.autoLogin.enable = true;

    # System Update
    #system.autoUpgrade.enable = false;
  };
}
