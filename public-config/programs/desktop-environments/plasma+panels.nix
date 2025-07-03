{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Main panel
  config.modules."plasma+panels" = {
    tags = config.modules."plasma".tags;
    attr = rec {
      widgets = {

        # Start menu
        startMenu = {
          name = "org.kde.plasma.kickoff";
          config = {
            "General" = {
              "icon" = "nix-snowflake"; # Icon
              "alphaSort" = true; # Sort by alphabet
            };
          };
        };

        # Activity pager
        activityPager = {
          name = "org.kde.plasma.activitypager";
          config = {
            "General" = {
              "pagerLayout" = "Vertical"; # Order top to bottom (More compact)
              "showWindowIcons" = true; # Small icons inside (Good to see which are being used)
              "displayedText" = "Number"; # Display a number inside
            };
          };
        };

        # Virtual desktop pager
        virtualDesktopsPager = {
          name = "org.kde.plasma.pager";
          config = {
            "General" = {
              "pagerLayout" = "Horizontal"; # Order left to right (Easier to click)
              "showWindowIcons" = true; # Small icons inside (Good to see which are being used)
              "displayedText" = "Number"; # Display a number inside
            };
          };
        };

        # Bar of apps
        taskManager = {
          name = "org.kde.plasma.taskmanager";
          config = {
            "General" = {
              "groupPopups" = false; # NEVER group icons!
              "onlyGroupWhenFull" = false; # NEVER group icons!
              "launchers" = (utils.joinStr "," [ # Pinned apps
                "applications:systemsettings.desktop" # Settings
                "applications:org.kde.konsole.desktop" # Konsole
                "applications:org.kde.dolphin.desktop" # Dolphin
              ]);
              "separateLaunchers" = false; # When clicked, replace the icon with the app. Do not keep the icon reserved!
              "showOnlyCurrentScreen" = true; # Show only apps on the current screen
              "wheelEnabled" = false; # Do not scroll through programs!
              "maxStripes" = 1; # Maximum of layers of apps
              #   Note: Two layers is good when there is a lot of open apps, but is harder to actually find anything as everything is smaller
              "indicateAudioStreams" = false; # Do not indicate apps that are playing sound
              "interactiveMute" = false; # Do not use the sound icon to toggle the app sound
              "taskMaxWidth" = "Narrow"; # Maximum width of open apps
            };
          };
        };

        # Separator
        separator = "org.kde.plasma.marginsseparator";

        # Spacer
        spacer = "org.kde.plasma.panelspacer";

        # System tray
        systemTray = {
          systemTray = { # From "plasma-manager/modules/widgets"
            icons = {
              spacing = "small"; # Spacing between items
              scaleToFit = false; # Do not increase items size (Multirow when the bar is thick)
            };
            items = {
              showAll = false; # Do not show all items!
              shown = [
                "org.kde.plasma.volume" # System volume
                "org.kde.plasma.networkmanagement" # Network status
              ];
              hidden = [
                "org.kde.plasma.brightness"
                "org.kde.kscreen"
                "org.kde.plasma.battery"
                "org.kde.plasma.printmanager"
                "org.kde.plasma.keyboardlayout"
                "org.kde.plasma.keyboardindicator"
                "org.kde.plasma.clipboard"
                "org.kde.plasma.manage-inputmethod"
                "org.kde.plasma.mediacontroller"
                "org.kde.plasma.vault"
              ];
            };
          };
        };

        # Clock
        clock = {
          name = "org.kde.plasma.digitalclock"; # Clock
          config = {
            "popupHeight" = 450; # Calendar popup height
            "popupWidth" = 400; # Calendar popup width
            "Appearance" = {
              "fontWeight" = 400; # Font
              "showSeconds" = "Always"; # Show seconds
              "use24hFormat" = 2; # Show 24h
              "enabledCalendarPlugins" = "holidaysevents"; # Show holidays
            };
          };
        };

        # Show desktop button
        showDesktop = "org.kde.plasma.showdesktop";

      };
      mainPanel = {
        location = "bottom"; # Place at the bottom of screen
        alignment = "center"; # Center the bar
        height = 42; # Size
        lengthMode = "fill"; # Cover the entire width
        floating = false; # Do not float
        hiding = "normalpanel"; # Stay on screen
        screen = "all"; # Appear on all screens
        opacity = "opaque"; # Opaque
        widgets = with widgets; [
          startMenu
          activityPager
          virtualDesktopsPager
          taskManager
          separator
          systemTray
          clock
          showDesktop
        ];
      };
    };
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Panels
        config.programs.plasma.panels = (utils.mkDefault) [ # (plasma-manager option)
          attr.mainPanel # Main panel
        ];

      };
    };
  };

  # Decrease the height of the total work-area
  config.hardware.configuration.screenSize.verticalBars = [ # (From "configurations/screen-size.nix")
    (utils.mkIf (config.includedModules."plasma+panels") (
      config.modules."plasma+panels".attr.mainPanel.height
    ))
  ];

}
