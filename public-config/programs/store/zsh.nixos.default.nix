{ config, pkgs-bundle, ... }@args: with args.config-utils; {

  options = {
    profile.programs.zsh = {
      options.enabled = (mkBoolOption true);
      options.packageChannel = (mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.zsh; {

    # ZSH: Shell
    programs.zsh = {
      enable = mkDefault options.enabled;
      #package = mkDefault options.packageChannel.zsh; # Option does not exist
    };

    # Default user shell
    users.defaultUserShell = ( # Cannot be "mkDefault" (Conflicts with bash)
      mkIf (options.enabled) (
        options.packageChannel.zsh
      )
    );

    # Allows autocompletion for system packages
    environment.pathsToLink = (
      mkIf (options.enabled) (
        [ "/share/zsh" ]
      )
    );

  };

}
