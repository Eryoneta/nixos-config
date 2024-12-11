{ ... }@args: with args.config-utils; {

  imports = [
    ../default/configuration.nix # Default
    ./hardware-configuration.nix # Scan de hardware
    ./hardware-fixes.nix # Hardware fixes
  ];

  config = {

    # Features/Swapfile
    swap.devices."basicSwap".size = ((16 + 2) * 1024); # 18GB

    # Programs/Grub
    boot.loader.grub.default = (utils.mkForce) 5; # Selects Windows 10 entry as default

  };

}
