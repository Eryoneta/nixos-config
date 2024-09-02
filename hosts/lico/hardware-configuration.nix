{ config, lib, pkgs, modulesPath, ... }: {

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

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
  networking.useDHCP = lib.mkDefault true;

  # Nix Packages
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Firmware
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

}
