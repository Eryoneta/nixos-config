{ ... }@args: with args.config-utils; {

  imports = [
    ../default/configuration.nix # Default
  ];

  config = {

    # Features/Autologin
    services.displayManager.autoLogin.enable = true;

    # Features/Swapfile
    swap.devices."basicSwap".size = ((4 + 2) * 1024); # 6GB

    # Features/ZRAM
    zramSwap.enable = false; # CPU is not really fast

  };

}
