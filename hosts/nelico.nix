{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # NeLiCo host
  config.modules."nelico" = {
    tags = [ "nelico" ];
    includeTags = [ "default-setup" ];
    setup = {
      nixos = { # (NixOS Module)

        # Features/Swapfile
        config.swap.devices."basicSwap".size = ((16 + 2) * 1024); # 16GB + 2GB = 18GB

        # Features/ZRAM
        config.zramSwap.memoryPercent = 50; # 16GB * 0.5 = 8GB

        # Bootloader/Grub: MemTest86
        config.boot.loader.grub.memtest86.enable = false; # Note: Enable if necessary

        # Features/AutoUpgrade
        config.system.autoUpgrade.alterProfile.configurationLimit = 8; # Just 8 is fine

        # Virtual machine (build-vm)
        config.virtualisation.vmVariant = {
          "virtualisation" = {
            "cores" = 6; # 6 CPU cores
            "memorySize" = (4 * 1024); # 4GB of RAM
          };
        };

        # Shared folder
        config.users.extraGroups = {
          "sharepoint" = {};
        };

      };
    };
  };

  # NeLiCo hardware
  config.modules."nelico-hardware" = {
    tags = config.modules."nelico".tags;
    setup = {
      nixos = { config, modulesPath, host, ... }: { # (NixOS Module)

        # For the not-detected hardware
        imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

        # Kernel
        config.boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
        config.boot.initrd.kernelModules = [ ];
        config.boot.kernelModules = [ "kvm-amd" ];

        # WiFi
        config.boot.extraModulePackages = [ config.boot.kernelPackages.rtl8192eu ];

        # Personal partition
        config.fileSystems."/home/${host.userDev.username}/Personal" = {
          device = "/dev/disk/by-label/Personal";
          fsType = "ext4";
        };

        # Basement partition
        config.fileSystems."/home/${host.userDev.username}/Personal/Mind Mansion/Basement" = {
          device = "/dev/disk/by-label/Basement";
          fsType = "ext4";
          depends = [ "/home/${host.userDev.username}/Personal" ];
          options = [ "nofail" ]; # Can be absent
        };

        # Storage partition
        config.fileSystems."/home/${host.userDev.username}/Personal/System_Utilities/Storage" = {
          device = "/dev/disk/by-label/Storage";
          fsType = "ext4";
          depends = [ "/home/${host.userDev.username}/Personal" ];
          options = [ "nofail" ]; # Can be absent
        };

        # Mirror partition
        config.fileSystems."/home/${host.userDev.username}/Personal/System_Utilities/Backups/Mirror" = {
          device = "/dev/disk/by-label/Mirror";
          fsType = "ext4";
          depends = [ "/home/${host.userDev.username}/Personal" ];
          options = [ "nofail" ]; # Can be absent
        };

        # Firmware
        config.hardware.cpu.intel.updateMicrocode = (utils.mkDefault) config.hardware.enableRedistributableFirmware;

        # Hardware-Fix: Enable SYSRQ for "R-E-I-S-U-B"
        config.boot.kernel.sysctl."kernel.sysrq" = 1;
        # Note: Sometimes, KWin might fatally freeze

      };
    };
  };

  # Screen size
  config.hardware.configuration.screenSize = ( # (From "configurations/screen-size.nix")
    utils.mkIf (config.includedModules."nelico") {
      width = 1366;
      height = 768;
    }
  );

}
