{ lib, config, pkgs, ... }@args: with args.config-utils; {

  options = {
    profile.programs.nix = {
      options.enabled = (utils.mkBoolOption true); # Always true
      options.packageChannel = (utils.mkPackageOption pkgs); # Not used
    };
  };

  config = with config.profile.programs.nix; (lib.mkIf (options.enabled) {

    # Nix: System package manager
    nix = {

      # Garbage Collector
      gc = {
        automatic = (utils.mkDefault) true;
        frequency = (utils.mkDefault) "*-*-* 17:00:00"; # Every day, 17h00
      };

    };

  });

}
