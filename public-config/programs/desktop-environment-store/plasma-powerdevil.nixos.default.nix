{ config, lib, ... }@args: with args.config-utils; {
  config = (
    with config.home-manager.users.${args.hostArgs.userDev.username};
    with profile.programs.plasma; (lib.mkIf (options.enabled) {

      systemd.sleep.extraConfig = utils.mkIf (options.enabled) (
        (utils.mkDefault) ''
          HibernateDelaySec=4h
        '' # Time after sleep before hibernation
      );

    })
  );
}
