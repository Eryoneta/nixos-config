{ tools, pkgs-bundle, config-domain, ... }: with tools; {
  config = {

    # Calibre: E-Book manager
    home = {
      packages = with pkgs-bundle.unstable-fixed; [ calibre ];
    };

    home.file.".config/calibre".source = (
      mkOutOfStoreSymlink "${config-domain.private.dotfiles}/calibre/.config/calibre"
    );

  };
}
