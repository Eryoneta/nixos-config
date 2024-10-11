{ config, pkgs-bundle, user, ... }@args: with args.config-utils; {
  config = {

    # Git: File versioning
    programs.git = (
      let
        package = pkgs-bundle.stable;
      in {
        enable = mkDefault true;
        package = mkDefault package.git;
        userName = mkDefault "${user.name}";
        userEmail = mkDefault "${user.username}@${user.host.hostname}";
        extraConfig = {
          init = {
            defaultBranch = "main";
          };
          merge = {
            conflictstyle = "diff3"; # diff with Delta
          };
        };
        aliases = {
          work = "checkout"; # "git work"
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
          enable = mkDefault true;
          package = mkDefault package.delta;
          options = mkDefault {
            line-numbers = true; # Show numbers
            side-by-side = true; # git diff shows changes side-by-side
            #hyperlinks = true; # Clickable links
            #hyperlinks-file-link-format = "vscode://file/{path}:{line}";
          };
        };

      }
    );

    # "git loglist"
    xdg.configFile."git/aliases/loglist" = {
      enable = (config.programs.git.enable);
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

    # "git save"
    xdg.configFile."git/aliases/save" = {
      enable = (config.programs.git.enable);
      text = ''
        [alias]
          # A shortcut for creating fast and simple commits
          #   Merges 'git add', 'git commit', and 'git push' into a single command!
          # The inputs can be at any order:
          #   "title":               Its the first string
          #   "message":             Its the second string. All other strings are ignored
          #   '--skip-add' or '-s':  Skips 'git add -A'
          #   '--amend' or '-a':     Appends '--amend' to 'git commit' and '--force' to 'git push'
          #   '--reamend' or '-r':   Appends '--amend --no-edit' to 'git commit' and '--force' to 'git push'
          #   '--push' or '-p':      Executes 'git push'
          # Ex.: 'git save --amend --push "Title" "Message"'
          # Ex.: 'git save "Title" -a "Message" -p'
          # Ex.: 'git save "Title" -pa "Message"'
          # Ex.: 'git save -rps' (Good for fixing mistakes)
          # Of course, '--amend' or '--reamend' and '--push' should not be used together in a team environment
          #   Never 'git push -f' with a team!
          save = "!f() { \
              local skip_add; \
              local amend; \
              local reamend; \
              local push; \
              local titulo; \
              local mensagem; \
              \
              for command in \"$@\"; do \
                case $command in \
                  '--skip-add') \
                    skip_add=true; \
                    ;; \
                  '--amend') \
                    amend=true; \
                    ;; \
                  '--reamend') \
                    reamend=true; \
                    ;; \
                  '--push') \
                    push=true; \
                    ;; \
                  *) \
                    if [[ ''${command:0:1} == '-' && ''${command:1:1} != '-' ]]; then \
                      for (( i=1; i<''${#command}; i++ )); do \
                        case ''${command:$i:1} in \
                          's') \
                            skip_add=true; \
                            ;; \
                          'a') \
                            amend=true; \
                            ;; \
                          'r') \
                            reamend=true; \
                            ;; \
                          'p') \
                            push=true; \
                            ;; \
                        esac; \
                      done; \
                    elif [[ -z $titulo ]]; then \
                      printf -v titulo %s \"$command\"; \
                    elif [[ -z $mensagem ]]; then \
                      printf -v mensagem %s \"$command\"; \
                    fi; \
                    ;; \
                esac; \
              done; \
              \
              if [[ -n $reamend && -n $titulo ]]; then \
                unset reamend; \
                amend=true; \
              fi; \
              \
              if [[ -z $skip_add ]]; then \
                if [[ -n $titulo || -n $amend || -n $reamend ]]; then \
                  echo \">> git add -A\"; \
                  git add -A; \
                  echo \"\"; \
                fi; \
              fi; \
              \
              if [[ -n $reamend ]]; then \
                echo \">> git commit --amend --no-edit\"; \
                git commit --amend --no-edit; \
                echo \"\"; \
              elif [[ -n $amend ]]; then \
                if [[ -n $titulo ]]; then \
                  if [[ -n $mensagem ]]; then \
                    echo \">> git commit --amend -m \\\"titulo\\\" -m \\\"mensagem\\\"\"; \
                    git commit --amend -m \"$titulo\" -m \"$mensagem\"; \
                    echo \"\"; \
                  else \
                    echo \">> git commit --amend -m \\\"titulo\\\"\"; \
                    git commit --amend -m \"$titulo\"; \
                    echo \"\"; \
                  fi; \
                else \
                  echo \">> git commit --amend\"; \
                  git commit --amend; \
                  echo \"\"; \
                fi; \
              else \
                if [[ -n $titulo ]]; then \
                  if [[ -n $mensagem ]]; then \
                    echo \">> git commit -m \\\"titulo\\\" -m \\\"mensagem\\\"\"; \
                    git commit -m \"$titulo\" -m \"$mensagem\"; \
                    echo \"\"; \
                  else \
                    echo \">> git commit -m \\\"titulo\\\"\"; \
                    git commit -m \"$titulo\"; \
                    echo \"\"; \
                  fi; \
                fi; \
              fi; \
              \
              if [[ -n $push ]]; then \
                if [[ -n $titulo || -n $amend || -n $reamend ]]; then \
                  if [[ -n $amend || -n $reamend ]]; then \
                    echo \">> git push -f\"; \
                    git push -f; \
                    echo \"\"; \
                  else \
                    echo \">> git push\"; \
                    git push; \
                    echo \"\"; \
                  fi; \
                fi; \
              fi; \
              \
              if [[ -n $titulo || -n $amend || -n $reamend ]]; then \
                echo \">> git status\"; \
                git status; \
                echo \"\"; \
              else \
                echo \"fatal: no commit message provided!\"; \
              fi; \
              \
            }; \
            f"
      '';
    };

    # "git quicksave"
    xdg.configFile."git/aliases/quicksave" = {
      enable = (config.programs.git.enable);
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

  };
}
