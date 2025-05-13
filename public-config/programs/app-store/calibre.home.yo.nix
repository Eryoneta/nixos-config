{ lib, ... }@args: with args.config-utils; {
  config.setup.modules."calibre" = {

    # Attributes
    tags = [ "yo" "hobby" ];
    attributes.enable = true;
    attributes.packageChannel = args.pkgs-bundle.stable;

    # Home-Manager
    home = { attributes }: {
      config = (lib.mkIf (attributes.enable) {

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

      });
    };

  };
}