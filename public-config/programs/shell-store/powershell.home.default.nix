{ config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {

  options = {
    profile.programs.powershell = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.powershell; {

    # PowerShell: Shell
    home.packages = utils.mkIf (options.enabled) (
      with options.packageChannel; [ powershell ]
    );

    # Profile
    # TODO: (PowerShell) Add my custom prompt

  };

}
