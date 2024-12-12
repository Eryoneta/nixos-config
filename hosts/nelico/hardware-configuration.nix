{ config, modulesPath, ... }@args: with args.config-utils; {

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = {

    # Kernel
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];

    # WiFi
    boot.extraModulePackages = [ config.boot.kernelPackages.rtl8192eu ];

    # Personal partition
    fileSystems."/home/yo/Personal" = {
      device = "/dev/disk/by-label/Personal";
      fsType = "ext4";
    };

    # Firmware
    hardware.cpu.intel.updateMicrocode = (utils.mkDefault) config.hardware.enableRedistributableFirmware;
    
  };

}
