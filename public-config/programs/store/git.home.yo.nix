{ config, pkgs-bundle, user, ... }@args: with args.config-utils; {
  config = {

    # Git: File versioning
    programs.git = {
      extraConfig = {
        merge = {
          ff = "false"; # Merge: Never fast-foward, always create a commit
        };
      };
      aliases = {
        merge-no-edit = "merge --no-edit"; # Don't edit commits of merges
      };
    };

  };
}
