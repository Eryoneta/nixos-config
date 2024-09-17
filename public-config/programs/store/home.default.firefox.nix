{ pkgs-bundle, user, ... }@args: with args.config-utils; {
  config = {

    # Firefox: Browser
    programs.firefox = {
      enable = mkDefault true;
      package = mkDefault pkgs-bundle.stable.firefox;
    };

  };
}
