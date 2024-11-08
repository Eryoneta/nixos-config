{ config, modules, host, ... }@args: with args.config-utils; {

  imports = with modules; [
    nixos-modules."swap-devices.nix"
    nixos-modules."swapfile-hibernation.nix"
  ];

  config = {

    # Kernel
    boot.initrd.availableKernelModules = (utils.mkDefault) [];
    boot.initrd.kernelModules = (utils.mkDefault) [];
    boot.kernelModules = (utils.mkDefault) [];
    boot.extraModulePackages = (utils.mkDefault) [];

    # Root partition
    fileSystems."/" = {
      device = (utils.mkDefault) "/dev/disk/by-label/NixOS";
      fsType = (utils.mkDefault) "ext4";
    };

    # Boot partition
    fileSystems."/boot" = {
      device = (utils.mkDefault) "/dev/disk/by-label/BOOT";
      fsType = (utils.mkDefault) "vfat";
      options = (utils.mkDefault) [ "fmask=0022" "dmask=0022" ];
    };

    # Swapfile ("swap-devices.nix")
    swap = {
      enable = (utils.mkDefault) true;
      devices = {
        "basicSwap" = {
          device = (utils.mkDefault) "/var/swapfile";
          size = (utils.mkDefault) (4 * 1024);
        };
      };
    };

    # ZRAM
    zramSwap = {
      enable = (utils.mkDefault) true;
      algorithm = (utils.mkDefault) "zstd"; # Compression algorithm
      memoryPercent = (utils.mkDefault) (
        100 # Total space shown(Not real compressed space!), in percent relative to RAM
      );
    };

    # Hibernation ("swapfile-hibernation.nix")
    system.hibernation = {
      enable = (utils.mkDefault) true;
      resumeDevice = config.fileSystems."/".device;
      swapfilePath = config.swap.devices."basicSwap".device;
      dataFile = {
        systemUser = host.user.username;
        path = "${host.configFolder}/hosts/${host.hostname}/hardware-data.json";
      };
    };

    # DHCP
    networking.useDHCP = (utils.mkDefault) true;

    # Nix Packages
    nixpkgs.hostPlatform = host.system.architecture;
    
  };

}
