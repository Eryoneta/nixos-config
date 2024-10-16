{ config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {

  options = {
    profile.programs.mpc-qt = {
      options.enabled = (mkBoolOption true);
      options.packageChannel = (mkPackageOption pkgs-bundle.unstable);
    };
  };

  config = with config.profile.programs.mpc-qt; {

    # MPC-QT: Multimidia player (A MPC-HC clone)
    home.packages = mkIf (options.enabled) (
      with options.packageChannel; [ mpc-qt ]
    );

    # Dotfiles
    xdg.configFile."mpc-qt/settings.json" = with config-domain; {
      enable = options.enabled;
      source = with public; (
        "${dotfiles}/mpc-qt/.config/mpc-qt/settings.json"
      );
    };
    xdg.configFile."mpc-qt/keys_v2.json" = with config-domain; { # Huh, it's v2 now
      enable = options.enabled;
      source = with public; (
        "${dotfiles}/mpc-qt/.config/mpc-qt/keys.json"
      );
    };

  };

}
