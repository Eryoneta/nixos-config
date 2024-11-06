{ config, modulesPath, ... }@args: with args.config-utils; {

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = {

    # Boot
    boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "ums_realtek" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    # Root Partition
    fileSystems."/" = {
      device = "/dev/disk/by-label/NixOS";
      fsType = "ext4";
    };

    # Boot Partition
    fileSystems."/boot" = {
      device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    # Feature/Swapfile: 6GB
    swap.devices."basicSwap".size = ((4 + 2) * 1024);

    # Feature/ZRAM: Disabled (CPU is not really fast)
    zramSwap.enable = false;

    # DHCP
    networking.useDHCP = (utils.mkDefault) true;

    # Nix Packages
    nixpkgs.hostPlatform = (utils.mkDefault) "x86_64-linux";

    # Firmware
    hardware.cpu.intel.updateMicrocode = (utils.mkDefault) config.hardware.enableRedistributableFirmware;
    
  };

}
