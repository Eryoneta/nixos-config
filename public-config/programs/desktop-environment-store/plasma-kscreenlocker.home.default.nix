{ config, lib, ... }@args: with args.config-utils; {
  config = with config.profile.programs.plasma; (lib.mkIf (options.enabled) {

    # KScreenLocker: Screen locker for Plasma
    programs.plasma.kscreenlocker = { # (plasma-manager option)

      # Appearance
      appearance = {
        alwaysShowClock = (utils.mkDefault) true; # Show time
        showMediaControls = (utils.mkDefault) true; # Show media controls
        wallpaper = (utils.mkDefault) ( # Wallpaper
          args.pkgs-bundle.nixos-artwork."wallpaper/nix-wallpaper-simple-blue.png"
        );
      };

      # Behaviour
      lockOnStartup = (utils.mkDefault) false; # Lock on startup
      lockOnResume = (utils.mkDefault) false; # Do not lock when resuming
      passwordRequired = (utils.mkDefault) true; # Requires password

      # AutoLock
      autoLock = (utils.mkDefault) false; # Do not autolock
      timeout = (utils.mkDefault) 10; # Time in minutes before autolock
      passwordRequiredDelay = (utils.mkDefault) 10; # Time in seconds after lock before requiring password

    };

  });
}
