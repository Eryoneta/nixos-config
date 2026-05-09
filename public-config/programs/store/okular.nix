{ config, userDev, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Okular: Document viewer
  config.modules."okular" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.system; # (Also included with KDE Plasma)
    attr.mkOutOfStoreSymlink = config.modules."configuration".attr.mkOutOfStoreSymlink;
    attr.mkSymlink = config.modules."configuration".attr.mkSymlink;
    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.okular ];

        # Dotfile
        config.programs.plasma.configFile."okularpartrc" = { # (plasma-manager option)
          "PageView" = {
            "MouseMode" = "TextSelect"; # Start with text selection tool
          };
        };

        # Dotfile: Toolbar
        config.xdg.dataFile."kxmlgui5/okular" = (
          # Only the developer should be able to modify the file
          (if (config.home.username == userDev.username) then attr.mkOutOfStoreSymlink else attr.mkSymlink) {
            public-dotfile = "okular/.local/share/kxmlgui5/okular";
          }
        );

      };
    };
  };

}
