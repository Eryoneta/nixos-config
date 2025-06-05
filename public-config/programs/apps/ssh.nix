{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # SSH: Secure connection
  config.modules."ssh" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      nixos = { config, ... }: { # (NixOS Module)

        # Configuration
        config.programs.ssh = {
          #enable = true; # Option does not exist
          package = (attr.packageChannel).openssh;
          startAgent = true; # Starts SSH Agent
        };

        # Fix: The system's SSH Agent doesn't set "SSH_AUTH_SOCK"...?
        # The variable is not set, but the agent is running, so set it
        config.environment.etc."profile" = {
          enable = (config.programs.ssh.startAgent);
          text = ''
            # Sets the variable, so the SSH Agent can be found
            # Shouldn't that be working by default...?
            export SSH_AUTH_SOCK="''${XDG_RUNTIME_DIR}/ssh-agent"
          '';
        };

      };
      home = { config-domain, ... }: { # (Home-Manager Module)

        # Configuration
        config.programs.ssh = {
          enable = true;
          package = (attr.packageChannel).openssh; # Stable channel
        };

        # SSH Agent
        config.services.ssh-agent.enable = false; # The system already starts the agent

        # Dotfile: Add GitHub's public keys
        config.home.file.".ssh/known_hosts" = (utils.mkDefault) (with config-domain; {
          source = with public; (
            "${dotfiles}/ssh/.ssh/known_hosts"
          );
        });

      };
    };
  };

}
