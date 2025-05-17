{ config, lib, ... }@args: with args.config-utils; {
  
  options = {
    profile.programs.plymouth = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption args.pkgs-bundle.stable); # Not used
    };
  };

  config = with config.profile.programs.plymouth; (lib.mkIf (options.enabled) {

    boot = {

      # Plymouth: Splash screen
      plymouth = {
        enable = options.enabled;
        theme = "breeze";
      };

      consoleLogLevel = 0; # No messages
      initrd.verbose = false; # Surpress NixOS Stages messages

      # Reference: https://wiki.nixos.org/wiki/Plymouth
      kernelParams = [
        "quiet" # Disable most log messages
        "splash" # There is a splash screen being shown, by "Plymouth"
        "boot.shell_on_fail" # If something goes wrong in "Stage 1", allow a root shell to be open
        "loglevel=3" # Print only the most important messages (Errors, criticals, alerts, and emergencies)
        "rd.systemd.show_status=false" # Hide "SystemD" messages
        "rd.udev.log_level=3" # Print only the most important messages from device manager
        "udev.log_priority=3" # Print only the most important messages from device manager
      ];

    };

  });

}
