{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Yakuake: Drop-down terminal
  config.modules."yakuake" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.yakuake ];

        # Shortcut
        config.programs.plasma.shortcuts = { # (plasma-manager option)
          "yakuake" = {
            "toggle-window-state" = "Meta+T"; # Toggle window view
          };
        };

        # Dotfile
        config.programs.plasma.configFile."yakuakerc" = { # (plasma-manager option)
            "Dialogs" = {
              "FirstRun" = false; # Do not show welcome-popup
            };
            "Window" = {
              "Width" = 80;
              "Height" = 80;
              "KeepOpen" = false; # Close when focus is lost
            };
            "Animation" = {
              "Frames" = 0; # Show instantly
            };
            "Appearance" = {
              "Translucency" = true; # Transparent
              "BackgroundColorOpacity" = 80;
            };
        };

        # Autostart
        config.xdg.configFile."autostart/org.kde.yakuake.desktop" = {
          text = utils.toINI {
            "Desktop Entry" = {
              "Name" = "Yakuake";
              "Icon" = "yakuake";
              "Type" = "Application";
              "Exec" = "yakuake";
              "Terminal" = false;
              "DBusActivatable" = true;
              "X-DBUS-ServiceName" = "org.kde.yakuake";
              "X-DBUS-StartupType" = "Unique";
              "X-KDE-StartupNotify" = false;
            };
          };
        };

      };
    };
  };

}
