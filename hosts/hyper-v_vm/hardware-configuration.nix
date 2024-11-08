{ config, ... }@args: with args.config-utils; {

  imports = [];

  config = {

    # Kernel
    boot.initrd.availableKernelModules = [ "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    # Swapfile
    swap.devices."basicSwap".size = ((4 + 2) * 1024); # 6GB

    # Firmware
    virtualisation.hypervGuest.enable = true;
    
  };

}
