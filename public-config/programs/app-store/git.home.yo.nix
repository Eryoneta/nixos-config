{ lib, config, ... }@args: with args.config-utils; {
  config = with config.profile.programs.git; (lib.mkIf (options.enabled) {

    # Git: File versioning
    programs.git = {
      extraConfig = {
        "merge" = {
          "ff" = "false"; # Merge: Never fast-forward, always create a commit
        };
      };
      aliases = {
        "merge-no-edit" = "merge --no-edit"; # Don't edit commits of merges
      };
    };

  });
}
