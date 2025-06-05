{ ... }@args: with args.config-utils; { # (Setup Module)

  # File system
  config.modules."file-system" = {
    tags = [ "default-setup" ];
    setup = {
      nixos = { # (NixOS Module)

        # Root partition
        config.fileSystems."/" = {
          device = (utils.mkDefault) "/dev/disk/by-label/NixOS";
          fsType = (utils.mkDefault) "ext4";
        };

        # Boot partition
        config.fileSystems."/boot" = {
          device = (utils.mkDefault) "/dev/disk/by-label/BOOT";
          fsType = (utils.mkDefault) "vfat";
          options = (utils.mkDefault) [ "fmask=0022" "dmask=0022" ];
        };

      };
    };
  };

}
