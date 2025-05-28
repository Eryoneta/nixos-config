{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."lico-host" = {

    # Configuration
    tags = [ "lico" ];
    includeTags = [ "default-setup" ];

    setup.nixos = { # (NixOS Module)

      imports = [
        ./hardware-configuration.nixos.nix # Hardware scan
        ./hardware-fixes.nixos.nix # Hardware fixes
      ];

      config = {

        # Features/Autologin
        services.displayManager.autoLogin.enable = true;

        # Features/Swapfile
        swap.devices."basicSwap".size = ((4 + 2) * 1024); # 6GB

        # Features/ZRAM
        zramSwap.enable = false; # CPU is not really fast

        # Features/AutoUpgrade
        system.autoUpgrade.alterProfile.configurationLimit = 4; # No need for more than that

      };

    };
  };
}
