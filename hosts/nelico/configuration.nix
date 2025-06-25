{ config, ... }@args: with args.config-utils; { # (Setup Module)

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

        # Virtual machine (build-vm)
        config.virtualisation.vmVariant = {
          "virtualisation" = {
            "cores" = 6; # 6 CPU cores
            "memorySize" = (6 * 1024); # 6GB of RAM
          };
        };

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
