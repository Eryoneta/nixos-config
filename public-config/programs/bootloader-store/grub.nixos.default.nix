{ config, ... }@args: with args.config-utils; {

  options = {
    profile.programs.grub = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable); # Not used
    };
  };

  config = with config.profile.programs.grub; {

    # Grub: Desktop Environment
    boot.loader.grub = {
      enable = (utils.mkDefault) options.enabled;

      efiSupport = true;
      device = "nodev";
      useOSProber = (utils.mkDefault) true; # Search for other OSs

      # Menus
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
      extraEntriesBeforeNixOS = true; # Extra menus at the top
      default = 3; # Selects NixOS entry as default
      configurationLimit = (utils.mkDefault) 100; # Max itens shown
      
    };

  };

}
