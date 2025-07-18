{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Plymouth: Splash screen
  config.modules."plymouth" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.system; # Not used
    setup = {
      nixos = { # (NixOS Module)

        # Boot
        config.boot = {

          # Configuration
          plymouth = {
            enable = true;
            theme = "breeze";
          };

          # Suppress messages
          consoleLogLevel = 0; # No messages
          initrd.verbose = false; # Surpress NixOS Stages messages
          kernelParams = [
            "quiet" # Disable most log messages
            "splash" # There is a splash screen being shown, by "Plymouth"
            "boot.shell_on_fail" # If something goes wrong in "Stage 1", allow a root shell to be open
            "loglevel=3" # Print only the most important messages (Errors, criticals, alerts, and emergencies)
            "rd.systemd.show_status=false" # Hide "SystemD" messages
            "rd.udev.log_level=3" # Print only the most important messages from device manager
            "udev.log_priority=3" # Print only the most important messages from device manager
          ];
          # Reference: https://wiki.nixos.org/wiki/Plymouth

        };

      };
    };
  };

}
