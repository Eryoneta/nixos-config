{ ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Git: File versioning
  config.modules."git.developer" = {
    tags = [ "developer-setup" ];
    setup = {
      home = { # (Home-Manager Module)

        # Configuration
        config.programs.git = {
          extraConfig = {
            "merge" = {
              "ff" = "false"; # Merge: Never fast-forward, always create a merge commit
            };
            "pull" = {
              "ff" = "only"; # Pull: Only fast-forward, never create a merge commit
            };
          };
          aliases = {
            "merge-no-edit" = "merge --no-edit"; # Don't edit commits of merges
          };
        };

      };
    };
  };

}
