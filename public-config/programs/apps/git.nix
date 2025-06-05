{ user, pkgs-bundle, config-domain, ... }@args: with args.config-utils; { # (Setup Module)

  # Git: File versioning
  config.modules."git" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    attr.git-tools = pkgs-bundle.git-tools;
    attr.userConfigByDir = profile: (with config-domain; (
      # Check for "./private-config/secrets"
      utils.mkIfElse (utils.pathExists private.secrets) (
        let
          userEmails = (utils.readJSONFile "${private.secrets}/${user.username}_emails.json");
        in {
          user = {
            name = userEmails.${profile}.username;
            email = userEmails.${profile}.address;
          };
        }
      ) {
        user = {
          name = null;
          email = null;
        };
      }
    ));
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Configuration
        config.programs.git = {
          enable = true;
          package = (utils.mkDefault) (attr.packageChannel).git;
          userName = (utils.mkDefault) user.name;
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
            { # My useful Git aliases!
              path = "${attr.git-tools}/.gitconfig";
            }
          ];

          # Delta: Git diff highlighter
          delta = {
            enable = (utils.mkDefault) true;
            package = (utils.mkDefault) (attr.packageChannel).delta;
            options = (utils.mkDefault) {
              "line-numbers" = true; # Show numbers
              "side-by-side" = true; # git diff shows changes side-by-side
              #"hyperlinks" = true; # Clickable links
              #"hyperlinks-file-link-format" = "vscode://file/{path}:{line}";
              # TODO: (ZSH/Delta) Check hyperlinks. Useful?
            };
          };

        };

      };
    };
  };

}
