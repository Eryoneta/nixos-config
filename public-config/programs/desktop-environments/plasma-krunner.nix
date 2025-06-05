{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # KRunner: Program starter for Plasma
  config.modules."plasma-krunner" = {
    tags = config.modules."plasma".tags;
    setup = {
      home = { # (Home-Manager Module)

        # Configuration
        config.programs.plasma.krunner = { # (plasma-manager option)
          activateWhenTypingOnDesktop = (utils.mkDefault) true; # Activate when typing on the desktop
          historyBehavior = (utils.mkDefault) "disabled"; # Do not use history
          position = (utils.mkDefault) "top"; # Open at the top
        };

      };
    };
  };

}
