{ config, pkgs-bundle,  ... }@args: with args.config-utils; {

  options = {
    profile.programs.kwrite = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable); # Not used
    };
  };

  config = with config.profile.programs.kwrite; {

    # KWrite: (Light) Text editor
    # (Included with KDE Plasma)

    # Dotfiles
    programs.plasma.configFile = utils.mkIf (options.enabled) {
      "kwriterc" = {
        "KTextEditor Document" = {
          "Newline at End of File" = false; # Do NOT add a newline!
        };
      };
    };

  };

}
