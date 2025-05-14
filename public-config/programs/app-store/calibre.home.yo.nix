{ ... }@args: with args.config-utils; {
  config.setup.modules."calibre" = {

    # Configuration
    enabled = true;
    tags = [ "yo" "hobby" ];
    attributes.packageChannel = args.pkgs-bundle.stable;

    # Home-Manager
    home = { attributes }: {

      # Calibre: E-Book manager
      home.packages = with attributes.packageChannel; [ calibre ];

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
}