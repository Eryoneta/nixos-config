{ config, pkgs-bundle, userDev, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # SSH: Secure connection
  config.modules."ssh" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    attr.mkSymlink = config.modules."configuration".attr.mkSymlink;
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
      home = { # (Home-Manager Module)

        # Configuration
        config.programs.ssh = {
          enable = true;
          package = (attr.packageChannel).openssh; # Stable channel
        };

        # SSH Agent
        config.services.ssh-agent.enable = false; # The system already starts the agent

        # Dotfile: Add GitHub's public keys
        config.home.file.".ssh/known_hosts" = (utils.mkDefault) (attr.mkSymlink {
          public-dotfile = "ssh/.ssh/known_hosts";
        });

      };
    };
  };

  # SSH: Secure connection
  config.modules."ssh.developer" = {
    tags = [ "sysdev-setup" "developer-setup" ];
    attr.mkOutOfStoreSymlink = config.modules."configuration".attr.mkOutOfStoreSymlink;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # SSH identities
        config.programs.ssh.matchBlocks = {
          "public" = {
            hostname = "github.com";
            identityFile = "~/.ssh/id_ed25519_git-public.pub";
            identitiesOnly = true;
            user = userDev.username;
          };
          "private" = {
            hostname = "github.com";
            identityFile = "~/.ssh/id_ed25519_git-private.pub";
            identitiesOnly = true;
            user = userDev.username;
          };
        };

        # Dotfile: Public key
        config.home.file.".ssh/id_ed25519_git-public.pub" = {
          text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAdTS2ls4g75x46nh7Q+t+kC9qASc9mlVmKXsEbF5xa/";
        };

        # Dotfile: Private key
        config.home.file.".ssh/id_ed25519_git-private.pub" = {
          text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKwDO7ottElr2R+o/R7l4rJ7sPhyTuMJwybqi0Syryb+";
        };

        # Dotfile: Known hosts
        config.home.file.".ssh/known_hosts" = (attr.mkOutOfStoreSymlink {
          private-dotfile = "ssh/.ssh/known_hosts";
        });

      };
    };
  };

}
