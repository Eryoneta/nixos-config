{ pkgs-bundle, config-domain, ... }@args: with args.config-utils; {
  config = {

    # MPC-QT: Multimidia player (A MPC-HC clone)
    home = {
      packages = with pkgs-bundle.unstable; [ mpc-qt ];
    };

    xdg.configFile."mpc-qt/settings.json" = with config-domain; {
      enable = (true);
      source = with public; (
        "${dotfiles}/mpc-qt/.config/mpc-qt/settings.json"
      );
    };
    xdg.configFile."mpc-qt/keys_v2.json" = with config-domain; { # Huh, it's v2 now
      enable = (true);
      source = with public; (
        "${dotfiles}/mpc-qt/.config/mpc-qt/keys.json"
      );
    };

  };
}
