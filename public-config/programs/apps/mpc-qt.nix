{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # MPC-QT: Multimidia player (A MPC-HC clone)
  config.modules."mpc-qt" = {
    enable = false; # DISABLED (Replaced by MPV)
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.unstable;
    setup = { attr }: {
      home = { config-domain, ... }: { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ mpc-qt ];

        # Dotfiles
        config.xdg.configFile."mpc-qt/settings.json" = with config-domain; {
          source = (
            "${public.dotfiles}/mpc-qt/.config/mpc-qt/settings.json"
          );
        };
        config.xdg.configFile."mpc-qt/keys_v2.json" = with config-domain; { # Huh, it's v2 now
          source = (
            "${public.dotfiles}/mpc-qt/.config/mpc-qt/keys.json"
          );
        };

      };
    };
  };

}
