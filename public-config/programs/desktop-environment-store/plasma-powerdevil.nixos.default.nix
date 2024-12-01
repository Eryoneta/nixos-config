{ lib, config, host, ... }@args: with args.config-utils; {
  config = (
    with config.home-manager.users.${host.user.username};
    with profile.programs.plasma; (lib.mkIf (options.enabled) {

      systemd.sleep.extraConfig = utils.mkIf (options.enabled) (
        (utils.mkDefault) ''
          HibernateDelaySec=4h
        '' # Time after sleep before hibernation
      );

    })
  );
}
