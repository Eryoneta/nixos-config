{ config, lib, ... }@args: with args.config-utils; {

  options = {
    profile.programs.mpc-qt = {
      options.enabled = (utils.mkBoolOption false); # DISABLED (Replaced by MPV)
      options.packageChannel = (utils.mkPackageOption args.pkgs-bundle.unstable);
    };
  };

  config = with config.profile.programs.mpc-qt; (lib.mkIf (options.enabled) {

    # MPC-QT: Multimidia player (A MPC-HC clone)
    home.packages = with options.packageChannel; [ mpc-qt ];

    # Dotfiles
    xdg.configFile."mpc-qt/settings.json" = with args.config-domain; {
      source = with public; (
        "${dotfiles}/mpc-qt/.config/mpc-qt/settings.json"
      );
    };
    xdg.configFile."mpc-qt/keys_v2.json" = with args.config-domain; { # Huh, it's v2 now
      source = with public; (
        "${dotfiles}/mpc-qt/.config/mpc-qt/keys.json"
      );
    };

  });

}
