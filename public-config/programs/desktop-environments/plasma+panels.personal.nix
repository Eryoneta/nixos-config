{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Plasma: A Desktop Environment focused on customization
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
                "chrome_status_icon_1" # Kando
                # TODO: (Kando) Watchout for the widget. The name might change!
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
            };
            "type2" = {
              "fixedLen" = 24; # Indicator height
              "labelSource" = 0; # Show virtual desktop number
            };
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

  # Decrease the height of the total work-area
  config.hardware.configuration.screenSize.verticalBars = [ # (From "configurations/screen-size.nix")
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
  ];
  config.hardware.configuration.screenSize.horizontalBars = [ # (From "configurations/screen-size.nix")
    (utils.mkIf (config.includedModules."plasma+panels.personal") (
      with config.modules."plasma+panels.personal"; (
        attr.helperPanel.height # Adds custom panel height
      )
    ))
  ];

}
