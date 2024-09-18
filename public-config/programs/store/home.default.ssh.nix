{ config-domain, pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # SSH: Secure connection
    programs.ssh = {
      enable = mkDefault true;
      package = mkDefault pkgs-bundle.stable.openssh;
    };
    services.ssh-agent.enable = false; # The system already starts the agent

    # Adds GitHub's public keys
    home.file.".ssh/known_hosts" = mkDefault (with config-domain; {
      source = mkOutOfStoreSymlink "${public.dotfiles}/ssh/.ssh/known_hosts";
    });

  };
}
