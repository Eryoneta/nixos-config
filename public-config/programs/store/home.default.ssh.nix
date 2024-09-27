{ config, config-domain, pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # SSH: Secure connection
    programs.ssh = {
      enable = true; # Always enabled
      package = pkgs-bundle.stable.openssh; # Stable
    };
    services.ssh-agent.enable = false; # The system already starts the agent

    # Adds GitHub's public keys
    home.file.".ssh/known_hosts" = mkDefault (with config-domain; {
      enable = (config.programs.ssh.enable);
      source = with outOfStore.public; (
        mkOutOfStoreSymlink "${dotfiles}/ssh/.ssh/known_hosts"
      );
    });

  };
}
