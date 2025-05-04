{ ... }@args: with args.config-utils; {

  imports = [
    ../default/configuration.nix # Default
    ./hardware-configuration.nix # Scan de hardware
    ./hardware-fixes.nix # Hardware fixes
  ];

  config = {

    # Features/Swapfile
    swap.devices."basicSwap".size = ((16 + 2) * 1024); # 18GB

    # Bootloader/Grub: MemTest86
    boot.loader.grub.memtest86.enable = false; # Note: Enable if necessary

    # Features/AutoUpgrade
    #system.autoUpgrade.alterProfile.configurationLimit = 8; # Upgrades are heavy! 256GB is not enough for 12 generations!
    # Note: Maybe it can handle 12... Testing

  };

}
