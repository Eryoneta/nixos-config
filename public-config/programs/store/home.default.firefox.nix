{ tools, pkgs-bundle, user, ... }: with tools; {
  config = {

    # Firefox: Browser
    programs.firefox = {
      enable = mkDefault true;
      package = mkDefault pkgs-bundle.stable.firefox;
    };

  };
}
