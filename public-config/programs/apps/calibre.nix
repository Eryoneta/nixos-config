{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Calibre: E-Book manager
  config.modules."calibre" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "yo" "interest" ];
    setup = { attr }: {
      home = { config-domain, ... }: { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ calibre ];

        # Dotfiles
        config.xdg.configFile."calibre" = with config-domain; {
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
