{ lib, config, pkgs-bundle, ... }@args: with args.config-utils; {

  options = {
    profile.programs.plasma = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable); # Not used
      options.defaults = (utils.mkDefaultsOption {
        "panels" = {};
        "plasmoids" = {};
      });
      options.activities = (utils.mkDefaultsOption {});
    };
  };

  config = with config.profile.programs.plasma; (lib.mkIf (options.enabled) {

    # Plasma: The KDE Plasma Desktop
    # Get current configurations with rc2nix: "nix run github:nix-community/plasma-manager > ~/Downloads/config.txt"
    programs.plasma = { # (plasma-manager option)
      enable = options.enabled;
      immutableByDefault = (utils.mkDefault) false; # Options can be changed by the user
      overrideConfig = (utils.mkDefault) false; # Do not delete configs set outside plasma-manager
      # TODO: (Plasma) Set to override all configs?

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
        # Wallpaper
        wallpaper = (utils.mkDefault) ( # Wallpaper
          pkgs-bundle.nixos-artwork."wallpaper/nix-wallpaper-simple-blue.png"
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
        mouseActions = {
          rightClick = "contextMenu"; # RightClick = Context menu
          middleClick = "applicationLauncher"; # MiddleClick = AppLauncher menu
          # verticalScroll = "switchActivity"; # Scroll = Switch activities
        };
      };
      # configFile."plasma-org.kde.plasma.desktop-appletsrc" = {
      #   "ActionPlugins/0" = { # Shift + Scroll = Switch virtual desktops
      #     "wheel:Vertical;ShiftModifier" = "org.kde.switchdesktop";
      #   };
      # };
      # Note: Using mouse scroll in the desktop for switching activities and virtual desktops might be cool, but I only use it by accident

      # Sessions
      session = {
        general.askForConfirmationOnLogout = true; # Show confirmation screen
        sessionRestore.restoreOpenApplicationsOnLogin = (
          "whenSessionWasManuallySaved" # Restore apps only when explicitly saved
        );
      };

      # Panels
      panels = (utils.mkDefault) [
        # Main
        options.defaults."panels"."main".panel
      ];

      # Windows
      windows.allowWindowsToRememberPositions = (utils.mkDefault) true; # Remember window positions

      # Window rules
      window-rules = (import ./plasma+window-rules.nix config.lib.hardware.configuration.screensize);

      # Shortcuts
      shortcuts = (import ./plasma+shortcuts.nix);

      # Language
      configFile."plasma-localerc" = { # Language: PT-BR
        "Formats" = {
          "LANG" = "pt_BR.UTF-8";
        };
        "Translations" = {
          "LANGUAGE" = "pt_BR";
        };
      };

    };
    
    hardware.configuration.screensize.verticalBars = [ # (Option of Hosts/Default/Hardware)
      options.defaults."panels"."main".panel.height
    ];

    profile.programs.plasma = { # Defines MainPanel
      options.defaults = {
        "panels"."main" = (import ./plasma+taskbar.nix { # Used as reference
          inherit utils;
        });
      };
      options.activities = (utils.mkDefault) rec { # Used as a placeholder
        list = { # Note: It's alfabetically ordered
          "main" = {
            id = "main-activity";
            name = "Main Activity";
            icon = "nix-snowflake-white";
          };
          "secondary" = {
            id = "secondary-activity";
            name = "Secondary Activity";
            icon = "kde-symbolic";
          };
        };
        startId = list."main".id;
      };
    };

  });

}
