{ config, userDev, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Kate: (Light) Code editor
  config.modules."kate" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.system; # (Also included with KDE Plasma)
    attr.mkOutOfStoreSymlink = config.modules."configuration".attr.mkOutOfStoreSymlink;
    attr.mkSymlink = config.modules."configuration".attr.mkSymlink;
    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.kate ];

        # Dotfile
        config.programs.plasma.configFile."katerc" = { # (plasma-manager option)
          "KTextEditor Document" = {
            "Newline at End of File" = false; # Do NOT add a newline!
            "Remove Spaces" = 0; # Do NOT remove spaces from EndOfLines!
          };
        };

        # Dotfile: Toolbar
        config.xdg.dataFile."kxmlgui5/katepart" = (
          # Only the developer should be able to modify the file
          (if (config.home.username == userDev.username) then attr.mkOutOfStoreSymlink else attr.mkSymlink) {
            public-dotfile = "kate/.local/share/kxmlgui5/katepart";
          }
        );

      };
    };
  };

}
