{ config, config-domain, pkgs-bundle, ... }@args: with args.config-utils; {

  options = {
    profile.programs.ssh = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.ssh; {

    # SSH: Secure connection
    programs.ssh = {
      enable = options.enabled; # Always enabled
      package = options.packageChannel.openssh; # Stable channel
    };
    services.ssh-agent.enable = false; # The system already starts the agent

    # Dotfiles: Adds GitHub's public keys
    home.file.".ssh/known_hosts" = utils.mkDefault (with config-domain; {
      enable = options.enabled;
      source = with public; (
        "${dotfiles}/ssh/.ssh/known_hosts"
      );
    });

  };

}
