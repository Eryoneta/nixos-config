{ ... }@args: with args.config-utils; {

  imports = [
    ../default/configuration.nix # Default
    ./hardware-configuration.nix # Scan de hardware
    ./hardware-fixes.nix # Hardware fixes
  ];

  config = {

    # Features/Autologin
    #services.displayManager.autoLogin.enable = true;

    # Features/AlterProfile
    system.autoUpgrade.alterProfile.configurationLimit = 2; # Keep only 2 generations

    # Boot-Loader
    boot.loader.grub.useOSProber = false; # No need for OS probing

    # Features/Swapfile
    swap.devices."basicSwap".size = ((4 + 2) * 1024); # 6GB

  };

}
