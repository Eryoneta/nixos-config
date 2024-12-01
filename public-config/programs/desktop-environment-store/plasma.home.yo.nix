{ lib, config, pkgs-bundle, ... }@args: with args.config-utils; {
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
      panels = [
        # Main
        (options.defaults."panels"."main".panel // {
          widgets = with options.defaults."panels"."main"; [
            options.defaults."plasmoids".tiledmenu
            widgets.activityPager
            widgets.virtualDesktopsPager
            (widgets.taskManager // {
              config = {
                "General" = (widgets.taskManager.config."General" // {
                  "launchers" = (utils.joinStr "," [ # Pinned apps
                    "applications:systemsettings.desktop" # Settings
                    "applications:org.kde.dolphin.desktop" # Dolphin
                    "applications:codium.desktop" # VSCodium
                    # "applications:org.kde.dolphin.desktop" # Dolphin
                    # "applications:firefox.desktop" # Firefox
                    # "applications:firefox-devedition.desktop" # Firefox-Dev
                    # TODO: (Plasma/Taskbar/Apps) Change later
                  ]);
                });
              };
            })
            widgets.separator
            (widgets.systemTray // {
              systemTray.items = (widgets.systemTray.systemTray.items // {
                shown = [
                  "org.kde.plasma.volume" # System volume
                  "org.kde.plasma.networkmanagement" # Network status
                ];
                hidden = (
                  widgets.systemTray.systemTray.items.hidden ++ [
                    "Yakuake" # Yakuake
                  ]
                );
              });
            })
            widgets.clock
            widgets.showDesktop
          ];
        })
      ];

    };

    # Icon theme
    xdg.dataFile."icons/Papirus-Colors-Dark" = {
      source = with pkgs-bundle; (
        papirus-colors-icons."Papirus-Colors-Dark"
      );
    };

  });

}
