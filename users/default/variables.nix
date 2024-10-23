{ config, ... }@args: with args.config-utils; {
  config = {

    # Variables
    home.sessionVariables = {
      EDITOR = utils.mkDefault "kwrite"; # Default Text Editor
      DEFAULT_BROWSER = utils.mkDefault "${config.programs.firefox.package}/bin/firefox"; # Default Browser
    };

  };
}
