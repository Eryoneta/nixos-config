{ config, modulesPath, ... }@args: with args.config-utils; {

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = {

    # Kernel
    boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "ums_realtek" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    # Boot partition
    fileSystems."/boot".device = "/dev/disk/by-label/EFI"; # Label is "EFI"

    # Swapfile
    swap.devices."basicSwap".size = ((4 + 2) * 1024); # 6GB

    # ZRAM
    zramSwap.enable = false; # CPU is not really fast

    # Firmware
    hardware.cpu.intel.updateMicrocode = (utils.mkDefault) config.hardware.enableRedistributableFirmware;
    
  };

}
