{ config, pkgs-bundle, ... }@args: with args.config-utils; {

  options = {
    profile.programs.ssh = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.ssh; {

    # SSH: Secure connection
    programs.ssh = { # Its always enabled
      #enable = options.enabled; # Option does not exist
      package = options.packageChannel.openssh; # Stable channel
      startAgent = true; # Starts SSH Agent
    };

    # Fix: The system's SSH Agent doesn't set "SSH_AUTH_SOCK"...?
    # The variable is not set, but the agent is running, so set it
    environment.etc."profile" = {
      enable = (options.enabled && config.programs.ssh.startAgent);
      text = ''
        # Sets the variable, so the SSH Agent can be found
        # Shouldn't that be working by default...?
        export SSH_AUTH_SOCK="''${XDG_RUNTIME_DIR}/ssh-agent"
      '';
    };

  };

}
