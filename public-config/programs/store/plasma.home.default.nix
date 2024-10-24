{ config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {

  options = {
    profile.programs.plasma = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable); # Not used
      options.defaults = (utils.mkDefaultsOption {
        panels = {
          main = (import ./plasma+taskbar.nix {
            inherit utils;
          });
        };
      });
    };
  };

  config = with config.profile.programs.plasma; {

    # Plasma: The KDE Plasma Desktop
    programs.plasma = {
      enable = utils.mkDefault options.enabled;

      # Workspace
      workspace = {
        clickItemTo = "select"; # When clicking files or folders, select them
        lookAndFeel = utils.mkDefault "org.kde.breezedark.desktop"; # Theme
        cursor = {
          theme = utils.mkDefault "Breeze"; # Cursor theme
          size = utils.mkDefault 32; # Cursor size
        };
        #iconTheme = utils.mkDefault ""; # TODO: Set default
        #wallpaper = utils.mkDefault ""; # TODO: Set default
      };

      # Panels
      panels = utils.mkDefault [
        # Main
        options.defaults.panels.main
      ];

    };

  };

}
