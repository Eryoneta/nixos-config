{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Plasma panels
  config.modules."plasma+panels" = {
    tags = config.modules."plasma".tags;
    attr = rec {
      widgets = {

        # Start menu
        startMenu = {
          name = "org.kde.plasma.kickoff";
          config = {
            "General" = {
              "icon" = "nix-snowflake-white"; # Icon
              "alphaSort" = true; # Sort by alphabet
              "highlightNewlyInstalledApps" = false; # Do not mark new apps
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

  # Plasma panels
  config.modules."plasma+panels.personal" = {
    tags = config.modules."plasma.personal".tags;
    attr = rec {
      packageChannel = pkgs-bundle.system; # (Also included with KDE Plasma)
      default-widgets = config.modules."plasma+panels".attr.widgets;
      default-mainPanel = config.modules."plasma+panels".attr.mainPanel;
      widgets = {

        # Bar of apps
        taskManager = (default-widgets.taskManager // {
          config = {
            "General" = (default-widgets.taskManager.config."General" // {
              "launchers" = (utils.joinStr "," [ # Pinned apps
                "applications:org.kde.dolphin.desktop" # Dolphin
                "applications:firefox.desktop" # Firefox
                "applications:firefox-devedition.desktop" # Firefox-Dev
              ]);
            });
          };
        });

        # Color Picker
        colorPicker = {
          name = "org.kde.plasma.colorpicker";
          config = {
            "General" = {
              "defaultFormat" = "RRGGBB";
            };
          };
        };

        # Weather
        weather = {
          name = "org.kde.plasma.weather";
          config = {
            "Appearance" = {
              "showHumidityInTooltip" = false; # Display only temperature and wind speed in tooltip
              "showTemperatureInCompactMode" = true; # Show temperature alongside
            };
            "WeatherStation" = {
              "source" = "bbcukmet|weather|São Paulo, Brazil, BR|3448439"; # Location and weather station id
            };
          };
        };
        # Note: Not used

        # System tray
        systemTray = (default-widgets.systemTray // {
          systemTray.items = (default-widgets.systemTray.systemTray.items // {
            shown = [
              "org.kde.plasma.vault" # Plasma Vault
              "org.kde.plasma.mediacontroller" # Media Controller
            ];
            hidden = (
              default-widgets.systemTray.systemTray.items.hidden ++ [
                "Yakuake" # Yakuake
                "Easy Effects" # Easy Effects
                "kando_status_icon_1" # Kando
                "org.kde.plasma.volume" # System volume
                "org.kde.plasma.networkmanagement" # Network status
              ]
            );
          });
        });

        # Volume
        volume = "org.kde.plasma.volume";

        # Network
        network = "org.kde.plasma.networkmanagement";

        # TiledMenu
        tiledmenu = (
          if (config.includedModules."plasma-tiledmenu.personal" or false) then (
            with config.modules."plasma-tiledmenu.personal"; ( # Custom
              attr.tiledmenu attr.apps attr.gridModel
            )
          ) else (
            with config.modules."plasma-tiledmenu"; ( # Default
              attr.tiledmenu attr.apps attr.gridModel
            )
          )
        );
        # Note: Not used

        # Configurable-Button
        configurablebutton = config.modules."plasma-configurablebutton".attr.configurablebutton;

        # Window-Title
        windowtitle = config.modules."plasma-windowtitle".attr.windowtitle;
        # Note: Not used

        # Kara
        kara = {
          name = "org.dhruv8sh.kara";
          config = {
            "general" = {
              "highlightType" = 2; # Square format
              "animationDuration" = 60; # 60ms of animation
              "wrapOn" = false; # Do not cicle back at the end
              "type" = 2; # Goes from 0 to 2. Here it actually refers to type3
            };
            "type2" = { # Text label option
              "fixedLen" = 24; # Indicator height
              "labelSource" = 0; # Show virtual desktop number
            }; # Note: Not used
            "type3" = { # Icon option
              "iconsList" = (utils.joinStr "\n" [
                "internet-services"
                "starred"
                "format-text-code"
              ]);
            };
            # Note: "typeN" goes from 1 to 3
          };
        };

        # Weather Widget Plus
        weatherwidgetplus = {
          name = "weather.widget.plus";
          config = {
            "Appearance" = {
              "iconSizeMode" = "Fixed"; # Icon has a fixed size
              "widgetIconSize" = 16; # 16px
              "textSizeMode" = "Fixed"; # Text has a fixed size
              "widgetFontSize" = 14; # 14px
              "layoutType" = "Vertical"; # Show both vertically
            };
            "Location" = {
              "places" = ''[{"providerId":"owm","placeIdentifier":"3448439","placeAlias":"São Paulo, BR","timezoneID":-1}]'';
            };
            "Units" = {
              "windSpeedType" = "kmh"; # Show speed in KM/H
            };
          };
        };

      };
      # helperPanel = (default-mainPanel // {
      #   height = 24; # Smaller
      #   widgets = with default-widgets; with widgets; [
      #     virtualDesktopsPager
      #     configurablebutton.showGrid
      #     separator
      #     configurablebutton.toggleYakuake
      #     spacer
      #     windowtitle
      #     spacer
      #     colorPicker
      #     weather
      #     systemTray
      #   ];
      # });
      # mainPanel = (default-mainPanel // {
      #   widgets = with default-widgets; with widgets; [
      #     tiledmenu
      #     activityPager
      #     taskManager
      #     separator
      #     volume
      #     network
      #     clock
      #     showDesktop
      #   ];
      # });
      # Note: Plasma 6.5 does not support stacks of panels...
      helperPanel = (default-mainPanel // {
        location = "right"; # Place at the right of the screen
        height = 28; # Smaller
        widgets = with default-widgets; with widgets; [
          kara
          colorPicker
          spacer
          systemTray
        ];
      });
      mainPanel = (default-mainPanel // {
        widgets = with default-widgets; with widgets; [
          startMenu
          activityPager
          separator
          configurablebutton.showGrid
          separator
          taskManager
          spacer
          separator
          weatherwidgetplus
          volume
          network
          clock
          configurablebutton.toggleYakuake
        ];
      });
    };
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Panels
        config.programs.plasma.panels = [# (plasma-manager option)
          attr.mainPanel # Main panel
          attr.helperPanel # Helper panel
        ];

        # Kara: Install
        config.home.packages = with attr.packageChannel; [ kara ];

        # Weather Widget Plus: Install
        config.xdg.dataFile."plasma/plasmoids/weather.widget.plus" = {
          source = "${pkgs-bundle.weatherwidgetplus}/weather.widget.plus";
        };

      };
    };
  };

  # Decrease the area of the total work-area
  #config.hardware.configuration.screenSize.verticalBars = [ # (From "configurations/screen-size.nix")
    # (utils.mkIf (config.includedModules."plasma+panels") (
    #   with config.modules."plasma+panels"; (
    #     -attr.mainPanel.height # Subtracts default panel height
    #   )
    # ))
    # (utils.mkIf (config.includedModules."plasma+panels.personal") (
    #   with config.modules."plasma+panels.personal"; (
    #     attr.mainPanel.height + attr.helperPanel.height # Adds custom panel height
    #   )
    # ))
    # Note: The default panel height is already included
  #];
  config.hardware.configuration.screenSize.horizontalBars = [ # (From "configurations/screen-size.nix")
    (utils.mkIf (config.includedModules."plasma+panels.personal") (
      with config.modules."plasma+panels.personal"; (
        attr.helperPanel.height # Adds custom panel height
      )
    ))
  ];

}
