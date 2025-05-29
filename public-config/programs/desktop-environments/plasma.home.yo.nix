{ config, lib, ... }@args: with args.config-utils; {
  config = with config.profile.programs.plasma; (lib.mkIf (options.enabled) {

    # Plasma: The KDE Plasma Desktop
    programs.plasma = { # (plasma-manager option)

      # Workspace
      workspace = {
        # Behaviour
        enableMiddleClickPaste = false; # Do not paste with middle-click (Too many accidents!)
        # UI
        cursor = {
          theme = null; # Managed by Stylix
          size = null; # Managed by Stylix
        };
        # Wallpaper
        wallpaper = null; # Managed by Stylix
        wallpaperFillMode = null; # Managed by Stylix
        # Themes
        theme = null; # Managed by Stylix
        lookAndFeel = null; # Managed by Stylix
        colorScheme = null; # Managed by Stylix
        iconTheme = "Papirus-Colors-Dark"; # Icons theme
        soundTheme = "Ocean"; # Sound theme
        # TODO: (Plasma/Themes/Sound) Test some other sound themes later
      };

      # Panels
      panels = (
        let

        # Bar of apps
          taskManager = with options.defaults."panels"."main"; (widgets.taskManager // {
            config = {
              "General" = (widgets.taskManager.config."General" // {
                "launchers" = (utils.joinStr "," [ # Pinned apps
                  "applications:org.kde.dolphin.desktop" # Dolphin
                  "applications:firefox.desktop" # Firefox
                  "applications:firefox-devedition.desktop" # Firefox-Dev
                ]);
              });
            };
          });

          # System tray
          systemTray = with options.defaults."panels"."main"; (widgets.systemTray // {
            systemTray.items = (widgets.systemTray.systemTray.items // {
              shown = [
                "org.kde.plasma.mediacontroller" # Media Controller
                "org.kde.plasma.vault" # Plasma Vault
              ];
              hidden = (
                widgets.systemTray.systemTray.items.hidden ++ [
                  "Yakuake" # Yakuake
                  "chrome_status_icon_1" # Kando
                  # TODO: (Kando) Watchout for the widget. The name might change!
                  "org.kde.plasma.volume" # System volume
                  "org.kde.plasma.networkmanagement" # Network status
                ]
              );
            });
          });

          # Show grid
          showGrid = {
            name = "org.kde.plasma.icon";
            config = {
              "localPath" = "/home/${args.userDevArgs.username}/.local/share/plasma_icons/ShowGrid.desktop";
            };
          };

        in [
          # Main
          (options.defaults."panels"."main".panel // {
            widgets = with options.defaults."panels"."main"; [
              options.defaults."plasmoids".tiledmenu
              widgets.activityPager
              taskManager
              widgets.separator
              "org.kde.plasma.volume"
              "org.kde.plasma.networkmanagement"
              widgets.clock
              widgets.showDesktop
            ];
          })
          # Extra
          (options.defaults."panels"."main".panel // {
            height = 24; # Size
            widgets = with options.defaults."panels"."main"; [
              widgets.virtualDesktopsPager
              showGrid
              widgets.spacer
              "org.kde.plasma.colorpicker"
              systemTray
            ];
          })
        ]
      );

      # Window rules
      window-rules = (import ./plasma+window-rules.yo.nix config.lib.hardware.configuration.screensize);

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
          "ExtraButton1" = "Key,Meta+Space"; # Button 9 = Meta + Space
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
    xdg.dataFile."icons/Papirus-Colors-Dark" = {
      source = with args.pkgs-bundle; (
        papirus-colors-icons."Papirus-Colors-Dark"
      );
    };

    # Grid view
    xdg.dataFile."plasma_icons/ShowGrid.desktop" = {
      text = (
        let
          showGridCommand = "qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut 'Grid View'";
        in ''
          [Desktop Entry]
          Name=Show Grid
          Name[pt_BR]=Mostrar grade
          GenericName=
          GenericName[pt_BR]=
          Icon=show-grid
          Exec=${showGridCommand}
          Comment=
          Comment[pt_BR]=
          MimeType=
          Path=
          StartupNotify=true
          Terminal=false
          TerminalOptions=
          Type=Application
          X-KDE-SubstituteUID=false
          X-KDE-Username=
        '' # Note: As generated by Plasma
      );
      executable = true;
    };

  });

}
