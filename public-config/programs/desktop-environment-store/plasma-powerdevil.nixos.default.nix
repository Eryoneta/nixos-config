{ config, host, ... }@args: with args.config-utils; {
  config = with config.home-manager.users.${host.user.username}.profile.programs.plasma; {

    systemd.sleep.extraConfig = utils.mkIf (options.enabled) (
      (utils.mkDefault) ''
        HibernateDelaySec=4h
      '' # Time after sleep before hibernation
    );

  };
}
