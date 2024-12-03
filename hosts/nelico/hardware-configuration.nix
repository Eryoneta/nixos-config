{ config, modulesPath, pkgs, ... }@args: with args.config-utils; {

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = {

    # Kernel
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.rtl8192eu ];

    # Firmware
    hardware.cpu.intel.updateMicrocode = (utils.mkDefault) config.hardware.enableRedistributableFirmware;
    
  };

}
