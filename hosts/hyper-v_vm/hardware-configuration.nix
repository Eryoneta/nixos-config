{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Hyper-V_VM host
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

}
