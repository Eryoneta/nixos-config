{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Alarm Clock Applet: Basic alarm clock
  config.modules."alarm-clock-applet" = {
    tags = [ "personal-setup" "work-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ alarm-clock-applet ];

        # Autostart
        config.xdg.configFile."autostart/alarm-clock-applet.desktop" = {
          enable = false;
          # Note: ...It doesn't seems to work? For some reason, "KDE Plasma" does not open it at startup
          #   The autoStart.sh script run by "Kando" can do it just fine
          text = utils.toINI {
            "Desktop Entry" = {
              "Name" = "Alarm Clock";
              "Icon" = "alarm-clock";
              "Type" = "Application";
              "Exec" = "GTK_THEME=HIGHCONTRAST alarm-clock-applet --hidden";
              # Note: The icons are... not good for dark themes
              "Terminal" = false;
            };
          };
        };

      };
    };
  };

}
