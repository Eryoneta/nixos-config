{ lib, config, user, pkgs-bundle, ... }@args: with args.config-utils; {

  options = {
    profile.programs.git = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.git; (lib.mkIf (options.enabled) {

    # Git: File versioning
    programs.git = {
      enable = options.enabled;
      package = (utils.mkDefault) (options.packageChannel).git;
      userName = (utils.mkDefault) "${user.name}";
      userEmail = (utils.mkDefault) "${user.username}@${user.host.hostname}";
      extraConfig = {
        "init" = {
          "defaultBranch" = "main";
        };
        "merge" = {
          "conflictstyle" = "diff3"; # diff with Delta
        };
      };
      includes = [
        {
          path = "${pkgs-bundle.git-tools}/.gitconfig"; # My useful Git aliases!
        }
      ];

      # Delta: Git diff highlighter
      delta = {
        enable = (utils.mkDefault) true;
        package = (utils.mkDefault) (options.packageChannel).delta;
        options = (utils.mkDefault) {
          "line-numbers" = true; # Show numbers
          "side-by-side" = true; # git diff shows changes side-by-side
          #"hyperlinks" = true; # Clickable links
          #"hyperlinks-file-link-format" = "vscode://file/{path}:{line}";
          # TODO: (ZSH/Delta) Check hyperlinks. Useful?
        };
      };

    };

  });

}
