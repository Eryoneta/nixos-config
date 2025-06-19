{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # ZSH: Shell
  config.modules."zsh" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.system;
    attr.mkSymlink = config.modules."configuration".attr.mkSymlink;
    setup = { attr }: {
      nixos = { # (NixOS Module)

        # Configuration
        config.programs.zsh = {
          enable = true;
          #package = (utils.mkDefault) (attr.packageChannel).zsh; # Option does not exist
        };

        # Default user shell
        config.users.defaultUserShell = ( # Cannot be "utils.mkDefault" (Conflicts with bash)
          (attr.packageChannel).zsh
        );

        # Allows autocompletion for system packages
        config.environment.pathsToLink = [ "/share/zsh" ];

      };
      home = { config, ... }: { # (Home-Manager Module)

        # Configuration
        config.programs.zsh = {
          enable = true;
          package = (utils.mkDefault) (attr.packageChannel).zsh;

          # AutoComplete
          enableCompletion = (utils.mkDefault) true;

          # AutoSuggest
          autosuggestion = {
            enable = (utils.mkDefault) true;
            strategy = [ "history" ]; # Suggests based on history
          };

          # Configuration
          dotDir = (
            let
              homePath = config.home.homeDirectory;
              configPath = config.xdg.configHome;
              # Warning: It replaces all instances of "/home/USER/"!
              # That might affect weird XDG-configHome paths like "/home/USER/something/home/USER/my-config"
              # But, "xdg.configHome" is almost always "/home/USER/.config", so... eh
              configRelPath = (builtins.replaceStrings [ "${homePath}/" ] [ "" ] configPath);
            in (
              "${configRelPath}/zsh" # Does not accept absolute paths
            )
          );
          enableVteIntegration = true;

          # Syntax Highlight
          # More at: https://github.com/zsh-users/zsh-syntax-highlighting/tree/master/docs/highlighters
          syntaxHighlighting = {
            enable = (utils.mkDefault) true;
            package = (utils.mkDefault) (attr.packageChannel).zsh-syntax-highlighting;
            highlighters = [ "root" "brackets" "cursor" ];
          };

          # History
          history = {
            ignoreDups = false; # Include duplicates
            expireDuplicatesFirst = true; # Expires duplicates first
            extended = true; # Entries with timestamp
            ignorePatterns = [
              "rm *"
              "cd *"
            ];
            size = (utils.mkDefault) 10000;
            path = "${config.xdg.dataHome}/zsh/zsh_history";
          };

          # Oh-My-ZSH: Customize ZSH
          oh-my-zsh = {
            enable = (utils.mkDefault) true;
            package = (utils.mkDefault) (attr.packageChannel).oh-my-zsh;

            # Plugins
            # More at: https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
            plugins = [
              "git" # Shortcuts for Git(Ex.: "gst" for "git status")
              "sudo" # Rewrites the previous command with "sudo" by typing "ESC" twice
            ];

            # Theme
            # More at: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
            #theme = "agnoster";
            # Note: Replaced by "Powerlevel10k Theme"

          };

          # Aliases
          shellAliases = {
            "gw" = "git work";
            "gs" = "git save";
            "gqs" = "git quicksave";
            "gll" = "git loglist";
            # Note: Inspired by "git" from "Oh-My-ZSH"
          };

          # Plugins
          plugins = [
            # ZSH-No-PS2: Enter with a incomplete command produces a newline instead of a PS2(Secondary prompt)
            {
              name = "zsh-no-ps2";
              src = (attr.packageChannel).fetchFromGitHub {
                owner = "romkatv";
                repo = "zsh-no-ps2";
                rev = "v1.0.0";
                sha256 = "sha256-blu8KEdF4IYEI3VgIkSYsd0RZsAHErj9KnC67MN5Jsw=";
              };
            }
          ];

          initContent = (
            # Powerlevel10k: Custom theme
            (let
              p10kConfigPath = "${config.xdg.configHome}/zsh/.p10k.zsh";
              powerlevel10k = (attr.packageChannel).zsh-powerlevel10k;
            in ''
              # Powerlevel10k Theme
              source "${powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
              test -f "${p10kConfigPath}" && source "${p10kConfigPath}"
            '')
            +
            # Any-Nix-Shell: "nix-shell", "nix run", and "nix develop" with ZSH instead of bash
            (let
              any-nix-shell = (attr.packageChannel).any-nix-shell;
            in ''
              # Any-Nix-Shell
              ${any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
            '')
          );

        };

        # Powerlevel10k packages
        config.home.packages = with attr.packageChannel; [
          zsh-powerlevel10k # Powerlevel10k: ZSH theme
          meslo-lgs-nf # Meslo Nerd Font: Font patched for Powerlevel10k
        ];

        # Dotfile: Powerlevel10k profile, as generated by "p10k configure"
        #   If the file is not present, the wizard is automatically started
        # To change it, delete the file(Should be a HM symlink-outOfStore)
        #   The wizard can overwrite ".p10k.zsh", but it cannot edit ".zshrc"(A HM Symlink)
        #   The file is already imported(If present) at the theme above
        #   Of course, HM will complain if there is a file where the symlink should be
        #     Just replace the one at "dotfiles"
        config.xdg.configFile."zsh/.p10k.zsh" = (attr.mkSymlink {
          public-dotfile = "zsh/.config/zsh/.p10k.zsh";
        });

      };
    };
  };

}
