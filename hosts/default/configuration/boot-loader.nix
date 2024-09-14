{ lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # Bootloader
      boot.loader = {

        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };

        timeout = mkDefault 10; # 10 seconds before selecting default option

        grub = {
          enable = true;
          efiSupport = true;
          device = "nodev";
          useOSProber = mkDefault true; # Finds Windows bootloader
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
          configurationLimit = mkDefault 100; # Max itens shown
        };
        
      };

    };
}
