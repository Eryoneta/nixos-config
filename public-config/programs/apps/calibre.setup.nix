{ ... }@args: with args.config-utils; { # Setup Module
  config.modules."calibre" = {

    # Configuration
    enabled = true;
    tags = [ "yo" "hobby" ];
    attr.packageChannel = args.pkgs-bundle.stable;

    # Home-Manager
    setup = { attr }: {
      home = { # Home-Manager Module

        # Calibre: E-Book manager
        home.packages = with attr.packageChannel; [ calibre ];

        # Dotfiles
        xdg.configFile."calibre" = with args.config-domain; {
          # Check for "./private-config/dotfiles"
          enable = (utils.pathExists private.dotfiles);
          source = with outOfStore.private; (
            utils.mkOutOfStoreSymlink "${dotfiles}/calibre/.config/calibre"
          );
        };

      };
    };

  };
}