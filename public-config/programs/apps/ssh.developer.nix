{ userDev, ... }@args: with args.config-utils; { # (Setup Module)

  # SSH: Secure connection
  config.modules."ssh.developer" = {
    tags = [ "sysdev-setup" "developer-setup" ];
    setup = {
      home = { config-domain, ... }: { # (Home-Manager Module)

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
        config.home.file.".ssh/known_hosts" = with config-domain; {
          # Check for "./private-config/dotfiles"
          enable = (utils.pathExists private.dotfiles);
          source = with outOfStore.private; (
            utils.mkOutOfStoreSymlink "${dotfiles}/ssh/.ssh/known_hosts"
          );
        };

      };
    };
  };

}
