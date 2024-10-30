{ config, ... }@args: with args.config-utils; {
  
  options = {
    profile.programs.sddm = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.sddm; {

    # SDDM: Display Manager
    services.displayManager.sddm = {
      enable = (utils.mkDefault) options.enabled;
      package = (utils.mkDefault) options.packageChannel.kdePackages.sddm;

      # Wayland
      wayland.enable = (utils.mkDefault) true; # Wayland support

    };

  };

}
