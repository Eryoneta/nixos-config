{ config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {

  options = {
    profile.programs.yakuake = {
      options.enabled = (mkBoolOption true);
      options.packageChannel = (mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.yakuake; {

    # Yakuake: Drop-down terminal
    home.packages = mkIf (options.enabled) (
      with options.packageChannel; [ kdePackages.yakuake ]
    );

    # Dotfiles
    xdg.configFile."yakuakerc" = {
      enable = options.enabled;
      text = mkFunc.toINI {
        Dialogs = {
          FirstRun = false; # Do not show welcome-popup
        };
        Window = {
          Width = 80;
          Height = 80;
          KeepOpen = false; # Close when focus is lost
        };
        Animation = {
          Frames = 0; # Show instantly
        };
        Appearance = {
          Translucency = true; # Transparent
          BackgroundColorOpacity = 80;
        };
      };
    };
    xdg.configFile."autostart/org.kde.yakuake.desktop" = { # Autostart
      enable = options.enabled;
      text = mkFunc.toINI {
        "Desktop Entry" = {
          Name = "Yakuake";
          Icon = "yakuake";
          Type = "Application";
          Exec = "yakuake";
          Terminal = false;
          DBusActivatable = true;
          X-DBUS-ServiceName = "org.kde.yakuake";
          X-DBUS-StartupType = "Unique";
          X-KDE-StartupNotify = false;
        };
      };
    };

  };

}
