{ config, pkgs-bundle, config-domain, user, ... }@args: with args.config-utils; {
  config = {

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

    home.file.".ssh/id_ed25519_git-public.pub" = {
      enable = (config.programs.ssh.enable);
      text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAdTS2ls4g75x46nh7Q+t+kC9qASc9mlVmKXsEbF5xa/";
    };
    home.file.".ssh/id_ed25519_git-private.pub" = {
      enable = (config.programs.ssh.enable);
      text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKwDO7ottElr2R+o/R7l4rJ7sPhyTuMJwybqi0Syryb+";
    };

    home.file.".ssh/known_hosts" = with config-domain; {
      enable = (config.programs.ssh.enable && (mkFunc.pathExists private.dotfiles));
      source = with outOfStore.private; (
        mkOutOfStoreSymlink "${dotfiles}/ssh/.ssh/known_hosts"
      );
    };

  };
}
