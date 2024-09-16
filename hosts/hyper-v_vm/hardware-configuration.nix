{ tools, config, ... }: with tools; {

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

    # Swap
    swapDevices = [
      {
        device = "/var/swapfile";
        size = (4 * 1024) + (2 * 1024);
      }
    ];

    # Hibernation
    boot.resumeDevice = config.fileSystems."/".device;
    boot.kernelParams = [ "resume_offset=3848192" ];

    # DHCP
    networking.useDHCP = mkDefault true;

    # Nix Packages
    nixpkgs.hostPlatform = mkDefault "x86_64-linux";

    # Firmware
    virtualisation.hypervGuest.enable = true;
    
  };

}
