{ config, lib, pkgs, modulesPath, ... }: {

  imports = [ ];

  # Boot
  boot.initrd.availableKernelModules = [ "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Root Partition
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5f91f6e8-4ebd-41ea-93b7-d75b44aa4bf0";
    fsType = "ext4";
  };

  # Boot Partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/16D2-48AB";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # Swap
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = (4 * 1024) + (2 * 1024);
    }
  ];

  # DHCP
  networking.useDHCP = lib.mkDefault true;

  # Nix Packages
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Firmware
  virtualisation.hypervGuest.enable = true;

}