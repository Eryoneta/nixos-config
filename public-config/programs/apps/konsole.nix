{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Konsole: Terminal
  config.modules."konsole" = {
    attr.packageChannel = pkgs-bundle.stable; # Not used (Included with KDE Plasma)
    tags = [ "yo" ];
    setup = {
      home = { config-domain, ... }: { # (Home-Manager Module)

        # Configuration
        config.programs.plasma.configFile."konsolerc" = { # (plasma-manager option)
          "Desktop Entry" = {
            "DefaultProfile" = "Yo.profile"; # Profile
          };
        };

        # Dotfile
        config.xdg.dataFile."konsole" = with config-domain; {
          source = with outOfStore.public; (
            utils.mkOutOfStoreSymlink "${dotfiles}/konsole/.local/share/konsole"
          );
        };

      };
    };
  };

}
