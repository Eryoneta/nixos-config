{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Konsole: Terminal
  config.modules."konsole" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.system; # (Also included with KDE Plasma)
    attr.mkOutOfStoreSymlink = config.modules."configuration".attr.mkOutOfStoreSymlink;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.konsole ];

        # Configuration
        config.programs.plasma.configFile."konsolerc" = { # (plasma-manager option)
          "Desktop Entry" = {
            "DefaultProfile" = "Yo.profile"; # Profile
          };
        };

        # Dotfile
        config.xdg.dataFile."konsole" = (attr.mkOutOfStoreSymlink {
          public-dotfile = "konsole/.local/share/konsole";
        });

      };
    };
  };

}
