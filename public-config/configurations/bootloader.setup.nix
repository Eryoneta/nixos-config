{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."basic-bootloader" = {

    # Configuration
    tags = [ "basic-setup" ];

    setup = {
      nixos = { # (NixOS Module)
        config = {

          # Bootloader
          boot.loader = {
            efi = {
              canTouchEfiVariables = true;
              efiSysMountPoint = "/boot";
            };
            timeout = (utils.mkDefault) 10; # 10 seconds before selecting default option
          };

        };
      };
    };
  };
}
