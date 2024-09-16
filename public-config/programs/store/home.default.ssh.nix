{ tools, pkgs-bundle, ... }: with tools; {
  config = {

    # SSH: Secure connection
    programs.ssh = {
      enable = mkDefault true;
      package = mkDefault pkgs-bundle.stable.openssh;
    };
    services.ssh-agent.enable = false; # The system already starts the agent

  };
}
