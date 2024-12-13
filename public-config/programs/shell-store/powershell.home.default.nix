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

    # My PowerShell-Prompt
    xdg.configFile."powershell/Microsoft.PowerShell_profile.ps1" = {
      source = "${pkgs-bundle.powershell-prompt}/Microsoft.PowerShell_profile.ps1";
    };

  });

}
