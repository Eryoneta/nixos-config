{ config, lib, ... }@args: with args.config-utils; {

  options = {
    profile.programs.grub = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption args.pkgs-bundle.stable); # Not used
    };
  };

  config = with config.profile.programs.grub; (lib.mkIf (options.enabled) {

    # Grub: Desktop Environment
    boot.loader.grub = {
      enable = options.enabled;

      # Utilities
      efiSupport = true;
      device = "nodev";
      useOSProber = (utils.mkDefault) true; # Search for other OSs

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
      theme = (utils.mkDefault) "${args.config-domain.public.dotfiles}/grub/blue-star-grub-theme/light";

    };

  });

}
