{ ... }@args: with args.config-utils; { # (Setup Module)

  # Grub: Bootloader
  config.modules."grub" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.system; # Not used
    setup = {
      nixos = { config-domain, ... }: { # (NixOS Module)

        # Configuration
        config.boot.loader.grub = {
          enable = true;

          # Utilities
          efiSupport = true;
          device = "nodev";
          useOSProber = (utils.mkDefault) true; # Search for any other OS

          # Menus
          extraEntries = ''
            menuentry "Firmware" --class driver {
              fwsetup
            }
            menuentry "Poweroff" --class shutdown {
              halt
            }
            menuentry "Reboot" --class restart {
              reboot
            }
          ''; # Extra menus
          extraEntriesBeforeNixOS = true; # Extra menus at the top
          default = 3; # Selects NixOS entry as default
          configurationLimit = (utils.mkDefault) 100; # Max itens shown

          # Theme
          splashImage = null; # No background image
          theme = (utils.mkDefault) "${config-domain.public.dotfiles}/grub/blue-star-grub-theme/light";

        };

      };
    };
  };

}
