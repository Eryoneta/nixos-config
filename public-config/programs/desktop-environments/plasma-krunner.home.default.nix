{ config, lib, ... }@args: with args.config-utils; {
  config = with config.profile.programs.plasma; (lib.mkIf (options.enabled) {

    # KRunner: Program starter for Plasma
    programs.plasma.krunner = { # (plasma-manager option)
      activateWhenTypingOnDesktop = (utils.mkDefault) true; # Activate when typing on the desktop
      historyBehavior = (utils.mkDefault) "disabled"; # Do not use history
      position = (utils.mkDefault) "top"; # Open at the top
    };

  });
}
