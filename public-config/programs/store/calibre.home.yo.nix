{ config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {

  options = {
    profile.programs.calibre = {
      options.enabled = (mkBoolOption true);
      options.packageChannel = (mkPackageOption pkgs-bundle.unstable-fixed);
    };
  };

  config = with config.profile.programs.calibre; {

    # Calibre: E-Book manager
    home.packages = mkIf (options.enabled) (
      with options.packageChannel; [ calibre ]
    );

    # Dotfiles
    xdg.configFile."calibre" = with config-domain; {
      # Check for "./private-config/dotfiles"
      enable = (options.enabled && (mkFunc.pathExists private.dotfiles));
      source = with outOfStore.private; (
        mkOutOfStoreSymlink "${dotfiles}/calibre/.config/calibre"
      );
    };

  };

}
