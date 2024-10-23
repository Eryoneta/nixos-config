{ config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {

  options = {
    profile.programs.calibre = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.unstable-fixed);
    };
  };

  config = with config.profile.programs.calibre; {

    # Calibre: E-Book manager
    home.packages = utils.mkIf (options.enabled) (
      with options.packageChannel; [ calibre ]
    );

    # Dotfiles
    xdg.configFile."calibre" = with config-domain; {
      # Check for "./private-config/dotfiles"
      enable = (options.enabled && (utils.pathExists private.dotfiles));
      source = with outOfStore.private; (
        utils.mkOutOfStoreSymlink "${dotfiles}/calibre/.config/calibre"
      );
    };

  };

}
