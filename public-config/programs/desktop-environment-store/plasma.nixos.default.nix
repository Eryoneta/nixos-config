{ config, ... }@args: with args.config-utils; {

  options = {
    profile.programs.plasma = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable); # Not used
    };
  };

  config = with config.profile.programs.plasma; {

    # Plasma: A "Desktop Environment" focused on customization
    services.desktopManager.plasma6 = {
      enable = (utils.mkDefault) options.enabled;
    };

  };

}
