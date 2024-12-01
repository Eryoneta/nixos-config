{ lib, config, pkgs-bundle,  ... }@args: with args.config-utils; {

  options = {
    profile.programs.kate = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.kate; (lib.mkIf (options.enabled) {

    # Kate: (Light) Code editor
    home.packages = with options.packageChannel; [ kdePackages.kate ];

    # Dotfile
    programs.plasma.configFile."katerc" = { # (plasma-manager option)
      "KTextEditor Document" = {
        "Newline at End of File" = false; # Do NOT add a newline!
      };
    };

  });

}
