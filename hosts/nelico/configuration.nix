{ ... }@args: with args.config-utils; {

  imports = [
    ../default/configuration.nix # Default
  ];

  config = {

    # Features/Swapfile
    swap.devices."basicSwap".size = ((16 + 2) * 1024); # 18GB

  };

}
