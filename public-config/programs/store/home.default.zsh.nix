{ config, pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # ZSH: Shell
    programs.zsh = (
      let
        package = pkgs-bundle.stable;
      in {
        enable = mkDefault true;
        package = mkDefault package.zsh;

        # AutoComplete
        enableCompletion = true;

        # AutoSuggest
        autosuggestion = {
          enable = true;
          # Only present at unstable branch
          # TODO: Enable once its included
          #strategy = [ "history" ]; # Suggests based on history
        };

        # Integration
        enableVteIntegration = true;
        dotDir = ".config/zsh";

        # Syntax Highlight
        # More at: https://github.com/zsh-users/zsh-syntax-highlighting/tree/master/docs/highlighters
        syntaxHighlighting = {
          enable = true;
          package = package.zsh-syntax-highlighting;
          highlighters = [ "root" "brackets" "cursor" ];
        };

        # History
        history = {
          ignoreDups = false; # Include duplicates
          expireDuplicatesFirst = true;
          extended = true; # Entries with timestamp
          ignorePatterns = [
            "rm *"
            "cd *"
          ];
          size = 10000;
          path = "${config.xdg.dataHome}/zsh/zsh_history";
        };

        # Oh-My-ZSH: Customize ZSH
        oh-my-zsh = {
          enable = true;
          package = package.oh-my-zsh;

          # Plugins
          # More at: https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
          plugins = [
            "git"
            "sudo"
          ];

          # Theme
          # More at: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
          theme = "agnoster";

        };

        # Aliases
        shellAliases = {
          "nixos-generations" = "nix-env --list-generations --profile /nix/var/nix/profiles/system";
        };
        
      }
    );

  };
}
