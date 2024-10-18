{ ... }@args: with args.config-utils; {

  imports = [
    ../default/configuration.nix # Default
    ./hardware-configuration.nix # Scan de hardware
    ./hardware-fixes.nix # Hardware fixes
  ];

  config = {

    # Feature/Autologin
    services.displayManager.autoLogin.enable = true;

    # Feature/AlterProfile: Keep only 2 generations
    system.autoUpgrade.alterProfile.configurationLimit = 2;

    # Boot-Loader: No need for OS probing
    boot.loader.grub.useOSProber = false;

  };

}
