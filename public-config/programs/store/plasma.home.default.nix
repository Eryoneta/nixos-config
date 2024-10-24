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
      enable = (utils.mkDefault) options.enabled;
      immutableByDefault = (utils.mkDefault) false; # Options can be changed by the user
      overrideConfig = (utils.mkDefault) false; # Do not delete configs set outside plasma-manager # TODO: Change?

      # Workspace
      workspace = {
        # Behaviour
        enableMiddleClickPaste = (utils.mkDefault) true; # Middle-click paste
        clickItemTo = (utils.mkDefault) "select"; # When clicking files or folders, select them
        # UI
        cursor = {
          theme = (utils.mkDefault) "Breeze"; # Cursor theme
          size = (utils.mkDefault) 32; # Cursor size
        };
        wallpaper = (utils.mkDefault) ( # Wallpaper
          "${pkgs-bundle.nixos-artwork}/wallpapers/nix-wallpaper-simple-blue.png"
        );
        wallpaperFillMode = (utils.mkDefault) "preserveAspectCrop"; # Resize and cut excess
        # TODO: (Plasma/Wallpaper)(24.11) Does not work(--fill-mode does not exist). Check later
        # Themes
        theme = (utils.mkDefault) "breeze-dark"; # Global Theme
          # Run "plasma-apply-desktoptheme --list-themes" for options
        lookAndFeel = (utils.mkDefault) "org.kde.breezedark.desktop"; # Theme
          # Run "plasma-apply-lookandfeel --list" for options
        colorScheme = (utils.mkDefault) "BreezeDark"; # Color theme
          # Run "plasma-apply-colorscheme --list-schemes" for options
        iconTheme = (utils.mkDefault) "Breeze-Dark"; # Icons theme
        soundTheme = (utils.mkDefault) "Ocean"; # Sound theme
      };

      # Desktop
      desktop = {
        icons = {
          alignment = (utils.mkDefault) "left"; # Align new items from left to right
          arrangement = (utils.mkDefault) "topToBottom"; # Put new items top to bottom
          folderPreviewPopups = (utils.mkDefault) true; # Show an arrow, which lets preview contents
          lockInPlace = (utils.mkDefault) false; # Items can be moved
          size = (utils.mkDefault) 2; # Size small
          sorting.mode = (utils.mkDefault) "manual"; # Items are ordered manually
        };
        widgets = (utils.mkDefault) [
          # TODO: (Plasma/Desktop) Add widgets?
        ];
      };

      # Panels
      panels = (utils.mkDefault) [
        # Main
        options.defaults.panels.main
      ];

      # Windows
      windows.allowWindowsToRememberPositions = (utils.mkDefault) true; # Remember window positions

      # Shortcuts
      shortcuts = {
          # TODO: (Plasma/Shortcuts) Add shortcuts
      };

    };

  };

}
