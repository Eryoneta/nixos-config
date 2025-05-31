{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Plasma: A Desktop Environment focused on customization
  config.modules."plasma" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "default-setup" ];
    setup = { attr }: {
      nixos = { pkgs, ... }: { # (NixOS Module)

        # Configuration
        config.services.desktopManager.plasma6 = {
          enable = true;
        };

        # System utilities
        config.environment.systemPackages = with attr.packageChannel; [
          wayland-utils # Wayland Utils: Used by Plasma to display information about Wayland
          aha # Ansi HTML Adapter: Used by Plasma to format information
          pciutils # PCI Utilities: Used by Plasma to display information about PCI
          kdePackages.qtimageformats # QTImageFormats: Tools for generating thumbnails (Includes .webp support)
          icoutils # IcoUtils: Tools for generating thumbnails for Windows files
        ];

        # FWUpd: Used by Plasma to update firmwares
        config.services.fwupd = {
          enable = (utils.mkDefault) true;
          package = (utils.mkDefault) (attr.packageChannel).fwupd;
        };

        # Do NOT include
        config.environment.plasma6.excludePackages = with pkgs; [
          kdePackages.elisa # Elisa: Music player (Not used)
        ];

      };
      home = { pkgs-bundle, ... }: { # (Home-Manager Module)

        # Note: To get current configurations with rc2nix: "nix run github:nix-community/plasma-manager > ~/Downloads/config.txt"

        # Configuration
        config.programs.plasma = { # (plasma-manager option)
          enable = true;
          immutableByDefault = (utils.mkDefault) false; # Options can be changed by the user
          overrideConfig = (utils.mkDefault) false; # Do not delete configs set outside Plasma-Manager
          # TODO: (Plasma) Set to override all configs?

          # Workspace
          workspace = {
            # Behaviour
            enableMiddleClickPaste = (utils.mkDefault) true; # Middle-click paste
            clickItemTo = (utils.mkDefault) "select"; # When clicking files or folders, select them
            # Cursor
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
              #verticalScroll = "switchActivity"; # Scroll = Switch activities
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

          # Windows
          windows.allowWindowsToRememberPositions = (utils.mkDefault) true; # Remember window positions

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

      };
    };
  };

}
