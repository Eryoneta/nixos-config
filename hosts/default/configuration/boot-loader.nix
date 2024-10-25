{ ... }@args: with args.config-utils; {
  config = {

    # Bootloader
    boot.loader = {

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };

      timeout = (utils.mkDefault) 10; # 10 seconds before selecting default option

      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = (utils.mkDefault) true; # Finds Windows bootloader
        extraEntries = ''
          menuentry "Firmware" {
            fwsetup
          }
          menuentry "Poweroff" {
            halt
          }
          menuentry "Reboot" {
            reboot
          }
        ''; # Extra menus
        extraEntriesBeforeNixOS = true; # Extra menus are not placed at the end, so its better above
        default = 3; # Selects NixOS entry as default
        configurationLimit = (utils.mkDefault) 100; # Max itens shown
      };
      
    };

  };
}
