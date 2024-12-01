{ lib, config, user, config-domain, ... }@args: with args.config-utils; {
  config = with config.profile.programs.ssh; (lib.mkIf (options.enabled) {

    # SSH: Secure connection
    programs.ssh = {
      matchBlocks = {
        "public" = {
          hostname = "github.com";
          identityFile = "~/.ssh/id_ed25519_git-public.pub";
          identitiesOnly = true;
          user = user.username;
        };
        "private" = {
          hostname = "github.com";
          identityFile = "~/.ssh/id_ed25519_git-private.pub";
          identitiesOnly = true;
          user = user.username;
        };
      };
    };

    # Dotfiles
    home.file.".ssh/id_ed25519_git-public.pub" = {
      text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAdTS2ls4g75x46nh7Q+t+kC9qASc9mlVmKXsEbF5xa/";
    };
    home.file.".ssh/id_ed25519_git-private.pub" = {
      text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKwDO7ottElr2R+o/R7l4rJ7sPhyTuMJwybqi0Syryb+";
    };
    home.file.".ssh/known_hosts" = with config-domain; {
      # Check for "./private-config/dotfiles"
      enable = (utils.pathExists private.dotfiles);
      source = with outOfStore.private; (
        utils.mkOutOfStoreSymlink "${dotfiles}/ssh/.ssh/known_hosts"
      );
    };

  });
}
