{ ... }@args: with args.config-utils; {

  imports = [
    ../default/configuration.nix # Default
    ./hardware-configuration.nix # Scan de hardware
    ./hardware-fixes.nix # Hardware fixes
  ];

  config = {

    # Features/Swapfile
    swap.devices."basicSwap".size = ((16 + 2) * 1024); # 18GB

    # Features/AlterProfile
    system.autoUpgrade.alterProfile.configurationLimit = 12; # Keep only 12 generations

  };

}
