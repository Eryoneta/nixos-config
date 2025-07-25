{ ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Bootloader
  config.modules."bootloader" = {
    tags = [ "default-setup" ];
    setup = {
      nixos = { # (NixOS Module)

        # Bootloader
        config.boot.loader = {
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
          };
          timeout = (utils.mkDefault) 10; # 10 seconds before selecting default option
        };

      };
    };
  };

}
