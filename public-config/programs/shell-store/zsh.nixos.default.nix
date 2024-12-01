{ lib, config, host, ... }@args: with args.config-utils; {
  config = (
    with config.home-manager.users.${host.user.username};
    with profile.programs.zsh; (lib.mkIf (options.enabled) {

      # ZSH: Shell
      programs.zsh = {
        enable = options.enabled;
        #package = (utils.mkDefault) options.packageChannel.zsh; # Option does not exist
      };

      # Default user shell
      users.defaultUserShell = ( # Cannot be "utils.mkDefault" (Conflicts with bash)
        options.packageChannel.zsh
      );

      # Allows autocompletion for system packages
      environment.pathsToLink = [ "/share/zsh" ];

    })
  );
}
