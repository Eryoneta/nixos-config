{ ... }@args: with args.config-utils; { # (Setup Module)

  # NeLiCo host
  config.modules."nelico" = {
    tags = [ "nelico" ];
    includeTags = [ "default-setup" ];
    setup = {
      nixos = { # (NixOS Module)

        # Features/Swapfile
        config.swap.devices."basicSwap".size = ((16 + 2) * 1024); # 16GB + 2GB = 18GB

        # Bootloader/Grub: MemTest86
        config.boot.loader.grub.memtest86.enable = false; # Note: Enable if necessary

        # Features/AutoUpgrade
        #config.system.autoUpgrade.alterProfile.configurationLimit = 8; # Upgrades are heavy! 256GB is not enough for 12 generations!
        # Note: Maybe it can handle 12... Testing

      };
    };
  };

  # Screen size
  config.hardware.configuration.screenSize = ( # (From "configurations/screen-size.nix")
    utils.mkIf (config.includedModules."nelico") {
      width = 1600;
      height = 900;
    }
  );

}
