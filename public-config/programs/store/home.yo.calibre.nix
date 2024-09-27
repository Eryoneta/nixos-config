{ pkgs-bundle, config-domain, ... }@args: with args.config-utils; {
  config = {

    # Calibre: E-Book manager
    home = {
      packages = with pkgs-bundle.unstable-fixed; [ calibre ];
    };

    xdg.configFile."calibre" = with config-domain; {
      enable = ((true) && (mkFunc.pathExists private.dotfiles));
      source = with outOfStore.private; (
        mkOutOfStoreSymlink "${dotfiles}/calibre/.config/calibre"
      );
    };

  };
}
