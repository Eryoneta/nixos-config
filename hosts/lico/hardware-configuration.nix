{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # LiCo host
  config.modules."lico-hardware" = {
    tags = config.modules."lico".tags;
    setup = {
      nixos = { config, pkgs, modulesPath, ... }: { # (NixOS Module)

        # For the not-detected hardware
        imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

        # Kernel
        config.boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "ums_realtek" "usb_storage" "sd_mod" ];
        config.boot.initrd.kernelModules = [ ];
        config.boot.kernelModules = [ "kvm-intel" ];
        config.boot.extraModulePackages = [ ];

        # Boot partition
        config.fileSystems."/boot".device = "/dev/disk/by-label/EFI"; # Label is "EFI"

        # Firmware
        config.hardware.cpu.intel.updateMicrocode = (utils.mkDefault) config.hardware.enableRedistributableFirmware;

        # Hardware-Fix: Delays Grub to load the display
        # That bug only affects slow computers (Race condition)
        # https://askubuntu.com/questions/182248/why-is-grub-menu-not-shown-when-starting-my-computer
        config.boot.loader.grub.extraInstallCommands = ''
          TEMP_FILE="/boot/grub/grubTEMP.tmp"
          GRUB_FILE="/boot/grub/grub.cfg"
          ${pkgs.coreutils}/bin/printf " \
            # Hardware-fix: Delays Grub to load the display\n \
            videoinfo\n \
            videoinfo\n\n \
          " | ${pkgs.coreutils}/bin/cat - $GRUB_FILE > $TEMP_FILE \
            && ${pkgs.coreutils}/bin/mv $TEMP_FILE $GRUB_FILE
        '';

        # Hardware-Fix: Dead touchpad
        config.services.libinput.touchpad.additionalOptions = ''
          Option "SendEventsMode" "disabled"
        '';

      };
    };
  };

}
