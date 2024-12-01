{ lib, config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {

  options = {
    profile.programs.calibre = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.unstable-fixed);
    };
  };

  config = with config.profile.programs.calibre; (lib.mkIf (options.enabled) {

    # Calibre: E-Book manager
    home.packages = with options.packageChannel; [ calibre ];

    # Dotfiles
    xdg.configFile."calibre" = with config-domain; {
      # Check for "./private-config/dotfiles"
      enable = (utils.pathExists private.dotfiles);
      source = with outOfStore.private; (
        utils.mkOutOfStoreSymlink "${dotfiles}/calibre/.config/calibre"
      );
    };

  });

}
