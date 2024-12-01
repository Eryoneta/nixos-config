{ lib, config, pkgs-bundle, ... }@args: with args.config-utils; {

  options = {
    profile.programs.powershell = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.powershell; (lib.mkIf (options.enabled) {

    # PowerShell: Shell
    home.packages = with options.packageChannel; [ powershell ];

    # Profile
    # TODO: (PowerShell) Add my custom prompt

  });

}
