{ ... }@args: with args.config-utils; {
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
}
