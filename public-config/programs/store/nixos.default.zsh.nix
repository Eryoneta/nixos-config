{ config, pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # ZSH: Shell
    programs.zsh = {
      enable = mkDefault true;
      #package = mkDefault pkgs-bundle.stable.zsh; # Option does not exist
    };
    users.defaultUserShell = ( # Cannot be "mkDefault" (Conflicts)
      mkIf (config.programs.zsh.enable) (
        pkgs-bundle.stable.zsh
      )
    );

    # Allows autocompletion for system packages
    environment.pathsToLink = (
      mkIf (config.programs.zsh.enable) (
        [ "/share/zsh" ]
      )
    );

  };
}
