{ config, pkgs-bundle,  ... }@args: with args.config-utils; {

  options = {
    profile.programs.kate = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.kate; {

    # Kate: (Light) Code editor
    home.packages = with options.packageChannel; [ kdePackages.kate ];

    # Dotfiles
    programs.plasma.configFile = utils.mkIf (options.enabled) {
      "katerc" = {
        "KTextEditor Document" = {
          "Newline at End of File" = false; # Do NOT add a newline!
        };
      };
    };

  };

}
