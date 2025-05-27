{ ... }@args: with args.config-utils; { # (Setup Module)

  imports = [ ../default.setup.nix ];
  config.enabledTags = [ "hyper-v_vm" ];

  config.modules."hyper-v_vm-host" = {

    tags = [ "hyper-v_vm" ];

    setup.nixos = { # (NixOS Module)

      imports = [
        ./hardware-configuration.nixos.nix # Hardware scan
        ./hardware-fixes.nixos.nix # Hardware fixes
      ];

      config = {

        # Features/Autologin
        #services.displayManager.autoLogin.enable = true;

        # Features/AlterProfile
        system.autoUpgrade.alterProfile.configurationLimit = 2; # Keep only 2 generations

        # Boot-Loader
        boot.loader.grub.useOSProber = false; # No need for OS probing

        # Features/Swapfile
        swap.devices."basicSwap".size = ((4 + 2) * 1024); # 6GB

      };

    };
  };
}
