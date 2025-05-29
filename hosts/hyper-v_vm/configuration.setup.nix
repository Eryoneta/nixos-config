{ config, ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."hyper-v_vm-host" = {

    # Configuration
    tags = [ "hyper-v_vm" ];
    includeTags = [ "default-setup" ];

    setup.nixos = { # (NixOS Module)

      imports = [
        ./hardware-configuration.nixos.nix # Hardware scan
        ./hardware-fixes.nixos.nix # Hardware fixes
      ];

      config = {

        # Features/Autologin
        services.displayManager.autoLogin.enable = true;

        # Features/AlterProfile
        system.autoUpgrade.alterProfile.configurationLimit = 2; # Keep only 2 generations

        # Bootloader/OSProber
        boot.loader.grub.useOSProber = false; # No need for OS probing

        # Features/Swapfile
        swap.devices."basicSwap".size = ((4 + 2) * 1024); # 6GB

      };

    };
  };

  # Screen size
  config.hardware.configuration.screenSize = ( # (From "configurations/screen-size.nix")
    utils.mkIf (config.includedModules."hyper-v_vm-host") {
      width = 800; # Stuck because of "nomodeset"
      height = 600;
    }
  );

}
