{ ... }@args: with args.config-utils; {

  imports = [];

  config = {

    # Kernel
    boot.initrd.availableKernelModules = [ "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    # Firmware
    virtualisation.hypervGuest.enable = true;
    
  };

}
