{ config, host, lib, ... }:
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
        timeout = mkDefault 10; # 10 segundos
        grub = {
          enable = true;
          efiSupport = true;
          device = "nodev";
          useOSProber = mkDefault true; # Localiza Windows 10
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
          ''; # Menus extras
          extraEntriesBeforeNixOS = true; # Menus-extras não ficam no fim da lista! Então melhor encima
          default = 3; # Menu seleciona NixOS como padrão
          configurationLimit = mkDefault 100; # Quantidade máxima de gerações exibidas
        };
      };

    };
}
