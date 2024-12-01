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
      package = (utils.mkDefault) options.packageChannel.git;
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
      aliases = {
        "work" = "checkout"; # "git work"
      };
      includes = [
        {
          path = "${config.xdg.configHome}/git/aliases/loglist";
        }
        {
          path = "${config.xdg.configHome}/git/aliases/save";
        }
        {
          path = "${config.xdg.configHome}/git/aliases/quicksave";
        }
      ];

      # Delta: Git diff highlighter
      delta = {
        enable = (utils.mkDefault) true;
        package = (utils.mkDefault) options.packageChannel.delta;
        options = (utils.mkDefault) {
          "line-numbers" = true; # Show numbers
          "side-by-side" = true; # git diff shows changes side-by-side
          #"hyperlinks" = true; # Clickable links
          #"hyperlinks-file-link-format" = "vscode://file/{path}:{line}";
          # TODO: (ZSH/Delta) Check hyperlinks. Useful?
        };
      };

    };

    # Dotfile: "git loglist"
    xdg.configFile."git/aliases/loglist" = {
      text = ''
        [alias]
          # Basically 'git log --graph --oneline', but pretty
          #   Tip: It accepts '--all'
          loglist = log \
            --graph \
            --abbrev-commit \
            --decorate \
            --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset) %C(white)%s%C(reset) %C(yellow)- %an%C(reset)'
      '';
    };

    # Dotfile: "git save"
    xdg.configFile."git/aliases/save" = {
      text = (import ./git+alias-save.nix);
    };

    # Dotfile: "git quicksave"
    xdg.configFile."git/aliases/quicksave" = {
      text = ''
        [alias]
          # Quick commit
          #   Executes 'git save' with title defined as the current date
          #     Date format: 'dd/mm/YYYY'
          #   It can be used the same way as 'git save', but the title pre-defined
          # Ex.: 'git quicksave --amend --push "Message"'
          quicksave = "!f() { \
              printf -v titulo '%(%d/%m/%Y)T' -1; \
              git save \"$titulo\" \"$@\"; \
            }; \
            f"
      '';
    };

  });

}
