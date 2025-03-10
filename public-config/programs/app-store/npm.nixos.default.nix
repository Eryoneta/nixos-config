{ lib, config, host, ... }@args: with args.config-utils; {
  config = (
    with config.home-manager.users.${host.userDev.username};
    with profile.programs.npm; (lib.mkIf (options.enabled) {

      programs.npm = {
        enable = options.enabled;
        package = (options.packageChannel).nodePackages.npm;
      };

    })
  );
}
