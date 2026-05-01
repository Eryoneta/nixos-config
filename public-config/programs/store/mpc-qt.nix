{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # MPC-QT: Multimidia player (A MPC-HC clone)
  config.modules."mpc-qt" = {
    enable = false; # DISABLED (Replaced by MPV)
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.unstable;
    attr.mkSymlink = config.modules."configuration".attr.mkSymlink;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ mpc-qt ];

        # Dotfiles
        config.xdg.configFile."mpc-qt/settings.json" = (attr.mkSymlink {
          public-dotfile = "mpc-qt/.config/mpc-qt/settings.json";
        });
        config.xdg.configFile."mpc-qt/keys_v2.json" = (attr.mkSymlink { # Huh, it's v2 now
          public-dotfile = "mpc-qt/.config/mpc-qt/keys.json";
        });

      };
    };
  };

}
