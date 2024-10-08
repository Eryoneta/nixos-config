{ config, pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # SSH: Secure connection
    programs.ssh = { # Its always enabled
      package = pkgs-bundle.stable.openssh; # Stable
      startAgent = true; # Starts SSH Agent
    };

    # Fix: The system's SSH Agent doesn't set "SSH_AUTH_SOCK"...?
    # The variable is not set, but the agent is running, so set it
    environment.etc."profile" = {
      enable = (config.programs.ssh.startAgent);
      text = ''
        # Sets it, so the SSH Agent can be found
        # Shouldn't that be working by default...?
        export SSH_AUTH_SOCK="''${XDG_RUNTIME_DIR}/ssh-agent"
      '';
    };

  };
}
