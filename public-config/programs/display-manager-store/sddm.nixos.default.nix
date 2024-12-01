{ lib, config, ... }@args: with args.config-utils; {
  
  options = {
    profile.programs.sddm = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.sddm; (lib.mkIf (options.enabled) {

    # SDDM: Display Manager
    services.displayManager.sddm = {
      enable = options.enabled;
      package = (utils.mkDefault) options.packageChannel.kdePackages.sddm;

      # Wayland
      wayland.enable = (utils.mkDefault) true; # Wayland support

    };

  });

}
