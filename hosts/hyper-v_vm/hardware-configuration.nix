{ ... }@args: with args.config-utils; {

  imports = [
    ./hardware-configuration.nix # Scan de hardware
    ./hardware-fixes.nix # Hardware fixes
  ];

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
