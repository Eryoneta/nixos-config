{ config, host, pkgs-bundle, ... }@args: with args.config-utils; {
  config = with config.home-manager.users.${host.user.username}.profile.programs.zsh; {

    # ZSH: Shell
    programs.zsh = {
      enable = (utils.mkDefault) options.enabled;
      #package = (utils.mkDefault) options.packageChannel.zsh; # Option does not exist
    };

    # Default user shell
    users.defaultUserShell = ( # Cannot be "utils.mkDefault" (Conflicts with bash)
      utils.mkIf (options.enabled) (
        options.packageChannel.zsh
      )
    );

    # Allows autocompletion for system packages
    environment.pathsToLink = (
      utils.mkIf (options.enabled) (
        [ "/share/zsh" ]
      )
    );

  };
}
