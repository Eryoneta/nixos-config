{ config, userDev, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Gwenview: Image viewer
  config.modules."gwenview" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.system; # (Also included with KDE Plasma)
    attr.mkOutOfStoreSymlink = config.modules."configuration".attr.mkOutOfStoreSymlink;
    attr.mkSymlink = config.modules."configuration".attr.mkSymlink;
    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.gwenview ];

        # Dotfile
        config.programs.plasma.configFile."gwenviewrc" = { # (plasma-manager option)
          "General" = {
            "HistoryEnabled" = false; # Do not show history
          };
          "ImageView" = {
            "MouseWheelBehavior" = "MouseWheelBehavior::Zoom"; # Mouse scroll = Zoom
          };
          "MainWindow" = {
            "MenuBar" = "Disabled"; # Do not show menu
          };
          "ThumbnailView" = {
            "LowResourceUsageMode" = true; # Speed above quality
            "Sorting" = "Sorting::Date"; # Sort by date
            "SortDescending" = true; # Newer first
          };
        };

        # Dotfile: Toolbar
        config.xdg.dataFile."kxmlgui5/gwenview" = (
          # Only the developer should be able to modify the file
          (if (config.home.username == userDev.username) then attr.mkOutOfStoreSymlink else attr.mkSymlink) {
            public-dotfile = "gwenview/.local/share/kxmlgui5/gwenview";
          }
        );

      };
    };
  };

}
