{ pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # SSH: Secure connection
    programs.ssh = {
      enable = mkDefault true;
      package = mkDefault pkgs-bundle.stable.openssh;
    };
    services.ssh-agent.enable = false; # The system already starts the agent

  };
}
