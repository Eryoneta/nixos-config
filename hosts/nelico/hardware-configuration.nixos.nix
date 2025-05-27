{ config, modulesPath, ... }@args: with args.config-utils; { # (NixOS Module)

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

    # Basement partition
    fileSystems."/home/yo/Personal/Mind Mansion/Basement" = {
      device = "/dev/disk/by-label/Basement";
      fsType = "ext4";
      depends = [ "/home/yo/Personal" ];
    };

    # Storage partition
    fileSystems."/home/yo/Personal/System_Utilities/Storage" = {
      device = "/dev/disk/by-label/Storage";
      fsType = "ext4";
      depends = [ "/home/yo/Personal" ];
    };

    # Mirror partition
    fileSystems."/home/yo/Personal/System_Utilities/Backups/Mirror" = {
      device = "/dev/disk/by-label/Mirror";
      fsType = "ext4";
      depends = [ "/home/yo/Personal" ];
    };

    # Firmware
    hardware.cpu.intel.updateMicrocode = (utils.mkDefault) config.hardware.enableRedistributableFirmware;

  };

}
