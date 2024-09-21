{ config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {
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
        dotDir = ".config/zsh"; # Does not accept absolute paths

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
          #theme = "agnoster";

        };

        # Aliases
        shellAliases = {
          nixos-generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
        };

        # Theme: Powerlevel10k
        initExtra = (
          let
            p10kConfigPath = "${config.xdg.configHome}/zsh/.p10k.zsh";
          in ''
            # Powerlevel10k Theme
            source "${package.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
            test -f "${p10kConfigPath}" && source "${p10kConfigPath}"
          ''
        );
        
      }
    );

    # Powerlevel10k packages
    home = {
      packages = with pkgs-bundle.unstable-fixed; [
        zsh-powerlevel10k # Powerlevel10k: A ZSH theme
        meslo-lgs-nf # Meslo Nerd Font: A font patched for Powerlevel10k
      ];
    };

    # Powerlevel10k profile, as generated by "p10k configure"
    #   If the file is not present, the wizard is automatically started
    # To change it, delete the file(Should be a HM symlink-outOfStore)
    #   The wizard can overwrite ".p10k.zsh", but it cannot edit ".zshrc"(A HM Symlink)
    #   The file is already imported(If present) at the theme above
    home.file.".config/zsh/.p10k.zsh" = with config-domain; {
      source = mkOutOfStoreSymlink "${public.dotfiles}/zsh/.config/zsh/.p10k.zsh";
    };

  };
}
