{ pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # ZSH: Shell
    programs.zsh = {
      enable = mkDefault true;
      #package = mkDefault pkgs-bundle.stable.zsh; # Option does not exist
    };
    users.defaultUserShell = pkgs-bundle.stable.zsh; # Cannot be "mkDefault"

    # Allows autocompletion for system packages
    environment.pathsToLink = [ "/share/zsh" ];

  };
}
