{ ... }@args: with args.config-utils; { # (Setup Module)

  # KScreenLocker: Screen locker for Plasma
  config.modules."plasma-kscreenlocker" = {
    tags = config.modules."plasma".tags;
    setup = {
      home = { pkgs-bundle, ... }: { # (Home-Manager Module)

        # Configuration
        config.programs.plasma.kscreenlocker = { # (plasma-manager option)

          # Appearance
          appearance = {
            alwaysShowClock = (utils.mkDefault) true; # Show time
            showMediaControls = (utils.mkDefault) true; # Show media controls
            wallpaper = (utils.mkDefault) ( # Wallpaper
              pkgs-bundle.nixos-artwork."wallpaper/nix-wallpaper-simple-blue.png"
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

      };
    };
  };

}
