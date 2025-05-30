{ ... }@args: with args.config-utils; { # (Setup Module)

  # LiCo host
  config.modules."lico" = {
    tags = [ "lico" ];
    includeTags = [ "default-setup" ];
    setup = {
      nixos = { # (NixOS Module)

        imports = [
          ./hardware-configuration.nixos.nix # Hardware scan
          ./hardware-fixes.nixos.nix # Hardware fixes
        ];

        # Features/Autologin
        config.services.displayManager.autoLogin.enable = true;

        # Features/Swapfile
        config.swap.devices."basicSwap".size = ((4 + 2) * 1024); # 6GB

        # Features/ZRAM
        config.zramSwap.enable = false; # CPU is not really fast

        # Features/AutoUpgrade
        config.system.autoUpgrade.alterProfile.configurationLimit = 4; # No need for more than that

      };
    };
  };

  # Screen size
  config.hardware.configuration.screenSize = ( # (From "configurations/screen-size.nix")
    utils.mkIf (config.includedModules."lico") {
      width = 1366;
      height = 768;
    }
  );

}
