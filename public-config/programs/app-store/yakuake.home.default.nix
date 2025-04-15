{ lib, config, pkgs-bundle, ... }@args: with args.config-utils; {

  options = {
    profile.programs.yakuake = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.yakuake; (lib.mkIf (options.enabled) {

    # Yakuake: Drop-down terminal
    home.packages = with options.packageChannel; [ kdePackages.yakuake ];

    # Shortcut
    programs.plasma.shortcuts = { # (plasma-manager option)
      # Format: "Action = Shortcut,DefaultShortcut,ShortcutTranslatedName"
      "yakuake" = {
        "toggle-window-state" = "Meta+T"; # Toggle window view
      };
    };

    # Dotfile
    programs.plasma.configFile."yakuakerc" = { # (plasma-manager option)
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
    xdg.configFile."autostart/org.kde.yakuake.desktop" = {
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

  });

}
