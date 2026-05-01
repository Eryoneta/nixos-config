{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Plasma: A Desktop Environment focused on customization
  config.modules."plasma" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.system;
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
      home = { # (Home-Manager Module)

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

  # Plasma: A Desktop Environment focused on customization
  config.modules."plasma.personal" = {
    tags = [ "personal-setup" ];
    attr.papirus-colors-icons = pkgs-bundle.papirus-colors-icons;
    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)

        # Configuration
        config.programs.plasma = { # (plasma-manager option)

          # Workspace
          workspace = {

            # Behaviour
            enableMiddleClickPaste = false; # Do not paste with middle-click (Too many accidents!)

            # Themes
            iconTheme = "Papirus-Colors-Dark"; # Icons theme
            soundTheme = "Ocean"; # Sound theme

          };

          # Mouse
          input.mice = [
            {
              enable = true;
              accelerationProfile = "none"; # Do not accelerate mouse
              acceleration = 1.00; # Max speed
              leftHanded = false; # Right handed
              middleButtonEmulation = false; # Left + Right should do nothing
              scrollSpeed = 1.0; # It's actually: "defaultSpeed * scrollSpeed"
              # Found in "/proc/bus/input/devices"
              name = "Gaming Mouse";
              productId = "2533";
              vendorId = "093a";
            }
          ];
          configFile."kcminputrc" = {
            "ButtonRebinds/Mouse" = {
              "ExtraButton1" = "Key,Meta+K"; # Button 9 = Meta + K
              "ExtraButton2" = "Key,Ctrl+S"; # Button 8 = Ctrl + S
            };
          };

          # Border colors
          configFile."kdeglobals" = {
            # Reference: https://stylix.danth.me/configuration.html
            "WM" = with config.lib.stylix.colors; {
              "frame" = "${base0D-rgb-r},${base0D-rgb-g},${base0D-rgb-b}"; # Border color of active window
              "inactiveFrame" = "${base01-rgb-r},${base01-rgb-g},${base01-rgb-b}"; # Border color of inactive window
            };
          };

          # Button size
          configFile."breezerc" = {
            "Windeco" = {
              "ButtonSize" = "ButtonLarge"; # Size of window buttons
            };
          };

          # KWin Window manager for Plasma
          kwin = {
            effects.dimInactive.enable = false; # Dim inactive screens
          };

        };

        # Icon theme
        config.xdg.dataFile."icons/Papirus-Colors-Dark" = {
          source = (
            (attr.papirus-colors-icons)."Papirus-Colors-Dark"
          );
        };

      };
    };
  };

}
