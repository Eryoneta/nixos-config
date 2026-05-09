{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Hyper-V_VM host
  config.modules."hyper-v_vm" = {
    tags = [ "hyper-v_vm" ];
    includeTags = [ "default-setup" ];
    setup = {
      nixos = { # (NixOS Module)

        # Features/Autologin
        config.services.displayManager.autoLogin.enable = true;

        # Features/AlterProfile
        config.system.autoUpgrade.alterProfile.configurationLimit = 2; # Keep only 2 generations

        # Bootloader/OSProber
        config.boot.loader.grub.useOSProber = false; # No need for OS probing

        # Features/Swapfile
        config.swap.devices."basicSwap".size = ((4 + 2) * 1024); # 6GB

      };
    };
  };

  # Hyper-V_VM hardware
  config.modules."hyper-v_vm-hardware" = {
    tags = config.modules."hyper-v_vm".tags;
    setup = {
      nixos = { # (NixOS Module)

        # Kernel
        config.boot.initrd.availableKernelModules = [ "sd_mod" "sr_mod" ];
        config.boot.initrd.kernelModules = [ ];
        config.boot.kernelModules = [ ];
        config.boot.extraModulePackages = [ ];

        # Firmware
        config.virtualisation.hypervGuest.enable = true;

        # Hardware-Fix: "Hyper-V" does NOT like "KDE Plasma". Only "NoModeSet" works...
        config.boot.kernelParams = ["nomodeset"];

      };
    };
  };

  # Screen size
  config.hardware.configuration.screenSize = ( # (From "configurations/screen-size.nix")
    utils.mkIf (config.includedModules."hyper-v_vm") {
      width = 800; # Stuck because of "nomodeset"
      height = 600;
    }
  );

}
