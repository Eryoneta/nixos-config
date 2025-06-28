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

  # Screen size
  config.hardware.configuration.screenSize = ( # (From "configurations/screen-size.nix")
    utils.mkIf (config.includedModules."hyper-v_vm") {
      width = 800; # Stuck because of "nomodeset"
      height = 600;
    }
  );

}
