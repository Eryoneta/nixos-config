{ config, ... }@args: with args.config-utils; {

  imports = [ ];

  config = {

    # Boot
    boot.initrd.availableKernelModules = [ "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    # Root Partition
    fileSystems."/" = {
      device = "/dev/disk/by-label/NixOS";
      fsType = "ext4";
    };

    # Boot Partition
    fileSystems."/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    # Feature/Swapfile: 6GB
    swap.devices."basicSwap".size = 4 + 2;

    # Hibernation
    boot.resumeDevice = config.fileSystems."/".device;
    boot.kernelParams = [ "resume_offset=3848192" ];

    # DHCP
    networking.useDHCP = (utils.mkDefault) true;

    # Nix Packages
    nixpkgs.hostPlatform = (utils.mkDefault) "x86_64-linux";

    # Firmware
    virtualisation.hypervGuest.enable = true;
    
  };

}
