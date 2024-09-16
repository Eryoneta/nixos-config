{ tools, config, modulesPath, ... }: with tools; {

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

    # Swap
    swapDevices = [
      {
        device = "/var/swapfile";
        size = (4 * 1024) + (2 * 1024);
      }
    ];

    # DHCP
    networking.useDHCP = mkDefault true;

    # Nix Packages
    nixpkgs.hostPlatform = mkDefault "x86_64-linux";

    # Firmware
    hardware.cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
    
  };

}
