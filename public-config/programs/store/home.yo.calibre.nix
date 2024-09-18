{ pkgs-bundle, config-domain, ... }@args: with args.config-utils; {
  config = {

    # Calibre: E-Book manager
    home = {
      packages = with pkgs-bundle.unstable-fixed; [ calibre ];
    };

    home.file.".config/calibre" = with config-domain; (
      mkIf (mkFunc.pathExists private.dotfiles) {
        source = mkOutOfStoreSymlink "${private.dotfiles}/calibre/.config/calibre";
      }
    );

  };
}
