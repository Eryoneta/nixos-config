{ config, lib, ... }@args: with args.config-utils; {

  options = {
    profile.programs.chromium = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption args.pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.chromium; (lib.mkIf (options.enabled) {

    # Chromium: Internet browser
    programs.chromium = {
      enable = (options.enabled);
      package = (utils.mkDefault) (options.packageChannel).chromium;

      # Extensions
      extensions = [
        { # UBlock Origin
          id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
        }
      ];

    };

  });

}
