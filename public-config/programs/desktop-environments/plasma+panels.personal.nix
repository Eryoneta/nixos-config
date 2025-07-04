{ config, user, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Plasma: A Desktop Environment focused on customization
  config.modules."plasma+panels.personal" = {
    tags = config.modules."plasma.personal".tags;
    attr = rec {
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

        # Configurable-Button
        configurablebutton = config.modules."plasma-configurablebutton".attr.configurablebutton;

        # Window-Title
        windowtitle = config.modules."plasma-windowtitle".attr.windowtitle;

      };
      helperPanel = (default-mainPanel // {
        height = 24; # Smaller
        widgets = with default-widgets; with widgets; [
          virtualDesktopsPager
          configurablebutton.showGrid
          separator
          configurablebutton.toggleYakuake
          spacer
          windowtitle
          spacer
          colorPicker
          systemTray
        ];
      });
      mainPanel = (default-mainPanel // {
        widgets = with default-widgets; with widgets; [
          tiledmenu
          activityPager
          taskManager
          separator
          volume
          network
          clock
          showDesktop
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

      };
    };
  };

  # Decrease the height of the total work-area
  config.hardware.configuration.screenSize.verticalBars = [ # (From "configurations/screen-size.nix")
    (utils.mkIf (config.includedModules."plasma+panels") (
      with config.modules."plasma+panels"; (
        -attr.mainPanel.height # Subtracts default panel height
      )
    ))
    (utils.mkIf (config.includedModules."plasma+panels.personal") (
      with config.modules."plasma+panels.personal"; (
        attr.mainPanel.height + attr.helperPanel.height # Adds custom panel height
      )
    ))
  ];

}
