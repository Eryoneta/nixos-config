{ ... }@args: with args.config-utils; {

  imports = [
    ../default/configuration.nix # Default
    ./hardware-configuration.nix # Scan de hardware
    ./hardware-fixes.nix # Hardware fixes
  ];

  config = {

    # Feature/Autologin
    services.displayManager.autoLogin.enable = true;

    # Feature/AlterProfile
    system.autoUpgrade.alterProfile.configurationLimit = 2; # Keep only 2 generations

    # Boot-Loader
    boot.loader.grub.useOSProber = false; # No need for OS probing

  };

}
