{ pkgs-bundle, user, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # Git: File versioning
      programs.git = {
        enable = mkDefault true;
        package = mkDefault pkgs-bundle.stable.git;
        userName = mkDefault "${user.name}";
        userEmail = mkDefault "${user.username}@${user.host.hostname}";
        extraConfig = {
          init = {
            defaultBranch = "main";
          };
        };
        includes = [
          {
            path = "~/.config/git/aliases/loglist";
          }
        ];
      };

      # "git loglist"
      home.file.".config/git/aliases/loglist".text = ''
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
  }
