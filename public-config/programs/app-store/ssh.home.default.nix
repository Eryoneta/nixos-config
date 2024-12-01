{ lib, config, config-domain, pkgs-bundle, ... }@args: with args.config-utils; {

  options = {
    profile.programs.ssh = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.ssh; (lib.mkIf (options.enabled) {

    # SSH: Secure connection
    programs.ssh = {
      enable = options.enabled;
      package = (options.packageChannel).openssh; # Stable channel
    };
    services.ssh-agent.enable = false; # The system already starts the agent

    # Dotfiles: Adds GitHub's public keys
    home.file.".ssh/known_hosts" = (utils.mkDefault) (with config-domain; {
      source = with public; (
        "${dotfiles}/ssh/.ssh/known_hosts"
      );
    });

  });

}
