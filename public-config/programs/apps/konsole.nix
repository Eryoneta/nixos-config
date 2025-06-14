{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Konsole: Terminal
  config.modules."konsole" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.system; # (Also included with KDE Plasma)
    setup = { attr }: {
      home = { host, config-domain, ... }: { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ kdePackages.konsole ];

        # Configuration
        config.programs.plasma.configFile."konsolerc" = { # (plasma-manager option)
          "Desktop Entry" = {
            "DefaultProfile" = "Yo.profile"; # Profile
          };
        };

        # Dotfile
        config.xdg.dataFile."konsole" = with config-domain; {
          source = (
            utils.mkIfElse (!host.system.virtualDrive) (
              utils.mkOutOfStoreSymlink "${outOfStore.public.dotfiles}/konsole/.local/share/konsole"
            ) (
              "${public.dotfiles}/konsole/.local/share/konsole"
            )
          );
        };

      };
    };
  };

}
