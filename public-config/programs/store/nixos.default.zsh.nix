{ pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # ZSH: Shell
    programs.zsh = {
      enable = true;
      # package = package.zsh; # Option does not exist
    };
    users.defaultUserShell = pkgs-bundle.stable.zsh;

    # Allows for autocompletion for system packages
    environment.pathsToLink = [ "/share/zsh" ];

  };
}
