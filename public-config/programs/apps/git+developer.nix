{ ... }@args: with args.config-utils; { # (Setup Module)

  # Git: File versioning
  config.modules."git+developer" = {
    tags = [ "developer-setup" ];
    setup = {
      home = { # (Home-Manager Module)

        # Configuration
        config.programs.git = {
          extraConfig = {
            "merge" = {
              "ff" = "false"; # Merge: Never fast-forward, always create a commit
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
